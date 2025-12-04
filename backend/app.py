from flask import Flask
from flask_cors import CORS
from config import Config
import db

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # Enable CORS
    CORS(app, supports_credentials=True, resources={r"/api/*": {"origins": "http://localhost:3000"}})

    # Initialize DB
    db.init_app(app)

    # Register blueprints
    from auth_routes import bp as auth_bp
    app.register_blueprint(auth_bp, url_prefix='/api')

    # Placeholder for other blueprints
    from viewer_routes import bp as viewer_bp
    app.register_blueprint(viewer_bp, url_prefix='/api/viewer')

    from admin_routes import bp as admin_bp
    app.register_blueprint(admin_bp, url_prefix='/api/admin')

    from reports_routes import bp as reports_bp
    app.register_blueprint(reports_bp, url_prefix='/api/admin/reports')

    @app.route('/')
    def index():
        return "Backend is running."

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, port=5000)
