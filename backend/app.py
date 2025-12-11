from flask import Flask
from flask_cors import CORS
from config import Config
import db
import os

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # Enable CORS - support both local development and Docker environment
    allowed_origins = [
        "http://localhost:3000",  # Local development
        "http://localhost",        # Docker frontend on port 80
        "http://127.0.0.1:3000",
        "http://127.0.0.1"
    ]
    
    # Add custom origin if specified in environment
    custom_origin = os.environ.get('FRONTEND_URL')
    if custom_origin:
        allowed_origins.append(custom_origin)
    
    CORS(app, supports_credentials=True, resources={r"/api/*": {"origins": allowed_origins}})

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
