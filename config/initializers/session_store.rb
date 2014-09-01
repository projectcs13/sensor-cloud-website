# Be sure to restart your server when you modify this file.

SensorCloud::Application.config.session_store :cookie_store,
    :key => '_sensor_cloud_session',
    :expire_after => 24.hours
