#include "a7105.h"
#include "esphome/core/log.h"
 
namespace esphome {
namespace a7105 {

void A7105::setup() {
  //ESP_LOGI(TAG, "A7105 setup started!");
  this->spi_setup();

  this->cs_->digital_write(false);
  delay(10);
  this->initialize();
  //ESP_LOGI(TAG, "SPI setup finished!");
  //PN532::setup();
}

void A7105::initialize() {
   struct reg_set {
    uint8_t reg;
    uint8_t val;
  };

  struct reg_set regs[] = {
      // 01100011 - enable auto rssi, auto if offset, fifo mode, adc
      // measurement
      {A7105_01_MODE_CONTROL, 0b01100011},

      // 00001111 - set FIFO length to 3 bytes (easy mode)
      {A7105_03_FIFOI, 0x03},

      // Set GIO1 to SPI data output (MISO)
      {A7105_0B_GPIO1_PIN_I, 0b011000},

      // 00000101 - use crystal for timing, set sys clock divider to 2, disable
      // clock generator
      {A7105_0D_CLOCK, 0x5},
      // Default has CSC0 = 0x1 (divider = 2), CGS = 0 (disable clock gen) and
      // XS=1 (crystal source)

      // 00000010 - data rate = Fsyck / 32 / n+1
      // 25 kbps
      {A7105_0E_DATA_RATE, 19},

      // {A7105_10_PLL_II, 0b10000000 /* dbl xtal freq */ | 0b0111 << 1 /* chan
      // spacing 500khz */},

      // 00101011 - TX frequency deviation = 186 KHz
      {A7105_15_TX_II, 0x2b},

      // 01100010 - disable frequency compensation, disable data invert,
      // bandwidth = 500 KHz, select up-side band
      {A7105_18_RX, 0x62},

      // 10000000 - LNA and mixer gain = 24dB, manual VGA calibrate
      {A7105_19_RX_GAIN_I, 0x80},

      // 00001010 - no options here
      {A7105_1C_RX_GAIN_IV, 0x0A},

      // 00000111 - reset code register 1. Is this accidental? raise bit 4 to
      // avoid reset and enable crc
      {A7105_1F_CODE_I, 0x07},

      // 00010111 - set demodulator default, code error tolerance to 1 bit,
      // preamble pattern detector to 16 bits
      {A7105_20_CODE_II, 0x17},

      // 00100111 - demodulator dc level is preamble average val
      {A7105_29_RX_DEM_TEST_I, 0x47},

      // FEC Disabled
      // CRC Disabled
      // ID Length 4 bytes
      // PML[1:0] Preamble length 4 bytes
      {A7105_1F_CODE_I, 0b00000111},

      // Initial channel
      {A7105_0F_PLL_I, 54},
  };
  this->reset();

  for (size_t i = 0; i < sizeof(regs) / sizeof(regs[0]); i++) {
    this->write_reg(regs[i].reg, regs[i].val);
  }

  // ID will be set from YAML configuration or lambdas
  this->set_power(7);
}

bool A7105::write_reg(uint8_t reg, uint8_t value) {
    // assert CS
    this->enable();

   // _spi.beginTransaction(SPISettings(A7105_SPI_FREQUENCY, MSBFIRST, SPI_MODE0));
    // write register
    this->transfer_byte(reg);
    // write value into register
    uint8_t ret = this->transfer_byte(value);
    // de-assert CS
    this->disable();
   // _spi.endTransaction();
    
    return true;
}
 
bool A7105::read_reg(uint8_t reg, uint8_t *value) {
    // assert CS
    this->enable();
    // write register and read value
    this->transfer_byte(_READ(reg));
    *value = this->transfer_byte(0);
    // de-assert CS
    this->disable();
    
    return true;
}
 
void A7105::strobe(enum A7105_State state) {
    // assert CS
    this->enable();

    // write strobe command
    uint8_t ret = this->transfer_byte(state);
    // de-assert CS
    this->disable();
    
    //return ret;
}
 
void A7105::write_data(const std::vector<uint8_t> &data, uint8_t channel) {
    // assert CS
    this->enable();
    this->transfer_byte(A7105_RST_WRPTR);
    this->transfer_byte(A7105_05_FIFO_DATA);
    for (size_t i = 0; i < data.size(); i++) {
        this->transfer_byte(data[i]);
    }
    this->disable();
    
    write_reg(A7105_0F_PLL_I, channel);
    strobe(A7105_TX);
}

void A7105::send_bed_command(uint32_t remote_id, int head_dir, int feet_dir, uint8_t channel) {
    uint32_t start_time = micros();
    std::lock_guard<std::mutex> lock(radio_mutex_);
    
    // Set the ID for this transmission
    set_id(remote_id);
    
    std::vector<uint8_t> cmd;
    
    // Determine which command based on directions
    if (head_dir != 0 && feet_dir != 0) {
        // Both moving
        if (head_dir == 1 && feet_dir == 1) {
            // Both up
            cmd = {0x99, 0x99, 0x00};
        } else if (head_dir == -1 && feet_dir == -1) {
            // Both down
            cmd = {0xaa, 0xaa, 0x00};
        } else {
            // Mixed directions - send individual commands
            if (head_dir == 1) {
                write_data({0x44, 0x44, 0x00}, channel);
            } else if (head_dir == -1) {
                write_data({0x55, 0x55, 0x00}, channel);
            }
            if (feet_dir == 1) {
                write_data({0x66, 0x66, 0x00}, channel);
            } else if (feet_dir == -1) {
                write_data({0x77, 0x77, 0x00}, channel);
            }
            uint32_t elapsed = micros() - start_time;
            ESP_LOGD("a7105", "send_bed_command (mixed) took %lu us", elapsed);
            return;
        }
    } else if (head_dir != 0) {
        // Only head moving
        if (head_dir == 1) {
            cmd = {0x44, 0x44, 0x00};
        } else if (head_dir == -1) {
            cmd = {0x55, 0x55, 0x00};
        }
    } else if (feet_dir != 0) {
        // Only feet moving
        if (feet_dir == 1) {
            cmd = {0x66, 0x66, 0x00};
        } else if (feet_dir == -1) {
            cmd = {0x77, 0x77, 0x00};
        }
    } else {
        // Nothing moving
        return;
    }
    
    if (!cmd.empty()) {
        write_data(cmd, channel);
    }
    
    uint32_t elapsed = micros() - start_time;
    ESP_LOGD("a7105", "send_bed_command took %lu us", elapsed);
}

 

void A7105::read_data(std::vector<uint8_t> &buffer, size_t len) {
    strobe(A7105_RST_RDPTR);

    buffer.resize(len);
    for (size_t i = 0; i < len; i++) {
        uint8_t read_value;
        read_reg(A7105_05_FIFO_DATA, &read_value);
        buffer[i] = read_value;
    }
}
 
void A7105::set_id(uint32_t id) {
    ESP_LOGI("a7105", "Setting id: 0x%lx", id);
    // assert CS
    this->enable();
    this->transfer_byte(A7105_06_ID_DATA);
    this->transfer_byte((uint8_t)(id >> 24) & 0xFF);
    this->transfer_byte((uint8_t)(id >> 16) & 0xFF);
    this->transfer_byte((uint8_t)(id >> 8) & 0xFF);
    this->transfer_byte((uint8_t)id & 0xFF);
    // de-assert CS
    this->disable();
}
 
void A7105::set_power(int32_t power) {
   /*
    Power amp is ~+16dBm so:
    TXPOWER_100uW  = -23dBm == PAC=0 TBG=0
    TXPOWER_300uW  = -20dBm == PAC=0 TBG=1
    TXPOWER_1mW    = -16dBm == PAC=0 TBG=2
    TXPOWER_3mW    = -11dBm == PAC=0 TBG=4
    TXPOWER_10mW   = -6dBm  == PAC=1 TBG=5
    TXPOWER_30mW   = 0dBm   == PAC=2 TBG=7
    TXPOWER_100mW  = 1dBm   == PAC=3 TBG=7
    TXPOWER_150mW  = 1dBm   == PAC=3 TBG=7
    */
    uint8_t pac, tbg;
    switch(power) {
        case 0: pac = 0; tbg = 0; break;
        case 1: pac = 0; tbg = 1; break;
        case 2: pac = 0; tbg = 2; break;
        case 3: pac = 0; tbg = 4; break;
        case 4: pac = 1; tbg = 5; break;
        case 5: pac = 2; tbg = 7; break;
        case 6: pac = 3; tbg = 7; break;
        case 7: pac = 3; tbg = 7; break;
        default: pac = 0; tbg = 0; break;
    };
    write_reg(a7105::A7105_28_TX_TEST, (pac << 3) | tbg);
}
 
void A7105::set_tx_rx_mode(enum TXRX_State mode) {
    // if(mode == TX_EN) {
    //     write_reg(A7105_0B_GPIO1_PIN_I, 0x33);
    //     write_reg(A7105_0C_GPIO2_PIN_II, 0x31);
    // } else if (mode == RX_EN) {
    //     write_reg(A7105_0B_GPIO1_PIN_I, 0x31);
    //     write_reg(A7105_0C_GPIO2_PIN_II, 0x33);
    // } else {
    //     //The A7105 seems to some with a cross-wired power-amp (A7700)
    //     //On the XL7105-D03, TX_EN -> RXSW and RX_EN -> TXSW
    //     //This means that sleep mode is wired as RX_EN = 1 and TX_EN = 1
    //     //If there are other amps in use, we'll need to fix this
    //     write_reg(A7105_0B_GPIO1_PIN_I, 0x33);
    //     write_reg(A7105_0C_GPIO2_PIN_II, 0x33);
    // }
}
 
int8_t A7105::reset() {
    write_reg(A7105_00_MODE, 0x00);
    delayMicroseconds(1000);

    // Set both GPIO as output and low
    uint8_t result;
    read_reg(A7105_10_PLL_II, &result);
    strobe(A7105_STANDBY);
    
    return result == 0x9E;
}
}
}