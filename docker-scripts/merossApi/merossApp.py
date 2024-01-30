from flask import Flask
from flask_cors import CORS
from meross.api.device import webToggleDeviceApi, webLoadDevicesApi
from meross.api.auth import webLogoutApi, webAuthApi, webCheckApi
from waitress import serve

app = Flask(__name__)

app.register_blueprint(webToggleDeviceApi.ToggleDeviceRoute)
app.register_blueprint(webLoadDevicesApi.LoadDevicesRoute)
app.register_blueprint(webAuthApi.AuthRoute)
app.register_blueprint(webCheckApi.CheckRoute)
app.register_blueprint(webLogoutApi.LogOutRoute)

apiCorsConfig = {
    "origins": "*",
    "methods": ["OPTIONS", "GET", "POST"],
    "allow_headers": "*"}

cors = CORS(app, resources={"/*": apiCorsConfig}, send_wildcard=True)

if __name__ == "__main__":
    serve(app, host="0.0.0.0", port=4449, ipv6=false, url_scheme='https')
