import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate, Link } from 'react-router-dom';
import './RegisterPage.css';

const RegisterPage = () => {
    const [formData, setFormData] = useState({
        username: '',
        password: '',
        fname: '',
        lname: '',
        street: '',
        city: '',
        state: '',
        zipcode: '',
        cid: '',
        security_question: '',
        security_answer: ''
    });
    const [error, setError] = useState('');
    const { register } = useAuth();
    const navigate = useNavigate();

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        // Basic validation
        if (Object.values(formData).some(val => val === '')) {
            setError('All fields are required');
            return;
        }
        try {
            await register(formData);
        } catch (err) {
            setError(err.error || 'Registration failed');
        }
    };

    return (
        <div className="register-page">
            <div className="register-card">
                <h2>Create Viewer Account</h2>
                <form onSubmit={handleSubmit}>
                    <input name="username" value={formData.username} onChange={handleChange} placeholder="Username" required />
                    <input name="password" type="password" value={formData.password} onChange={handleChange} placeholder="Password" required />
                    <input name="fname" value={formData.fname} onChange={handleChange} placeholder="First Name" required />
                    <input name="lname" value={formData.lname} onChange={handleChange} placeholder="Last Name" required />
                    <input name="street" value={formData.street} onChange={handleChange} placeholder="Street" required />
                    <input name="city" value={formData.city} onChange={handleChange} placeholder="City" required />
                    <input name="state" value={formData.state} onChange={handleChange} placeholder="State" required />
                    <input name="zipcode" value={formData.zipcode} onChange={handleChange} placeholder="Zipcode" required />
                    <input name="cid" type="number" value={formData.cid} onChange={handleChange} placeholder="Country ID" required />
                    <input name="security_question" value={formData.security_question} onChange={handleChange} placeholder="Security Question" required />
                    <input name="security_answer" value={formData.security_answer} onChange={handleChange} placeholder="Security Answer" required />
                    
                    {error && <p className="error-message">{error}</p>}
                    <button type="submit">Register</button>
                </form>
                <p>Already have an account? <Link to="/login">Login</Link></p>
            </div>
        </div>
    );
};

export default RegisterPage;
