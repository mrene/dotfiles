import esphome.codegen as cg
import esphome.config_validation as cv
from esphome.components import spi
from esphome.const import CONF_ID
from esphome.const import (
    CONF_OUTPUT_ID,
    CONF_CS_PIN,
)

DEPENDENCIES = ["spi"]

CONF_A7105_ID = "a7105_id"

a7105_ns = cg.esphome_ns.namespace("a7105")
A7105Component = a7105_ns.class_("A7105", cg.Component, spi.SPIDevice)

CONFIG_SCHEMA = cv.Schema(
    {
        cv.GenerateID(): cv.declare_id(A7105Component),
    }).extend(spi.spi_device_schema(cs_pin_required=True)
)

FINAL_VALIDATE_SCHEMA = spi.final_validate_device_schema(
    "a7105", require_mosi=True, require_miso=False
)

async def to_code(config):
    var = cg.new_Pvariable(config[CONF_ID])
    await cg.register_component(var, config)
    await spi.register_spi_device(var, config)