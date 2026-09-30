import QtQuick
import Bloom.Services.Weather
QtObject {
    readonly property var instance: Weather
    property string city: Weather.city
    property double temperature: Weather.temperature
    property string condition: Weather.condition
    property double wind: Weather.wind
    property double humidity: Weather.humidity
    property double pressure: Weather.pressure
    property string updatedAt: Weather.updatedAt
}
