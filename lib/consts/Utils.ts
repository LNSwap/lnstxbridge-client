import { ConfigType } from "../../lib/Config";

let config: ConfigType;
export function setConfig(newConfig: ConfigType) {
    config = newConfig
}
export function getConfig() {
    return config;
}