import axios from 'axios';

const axiosClient = axios.create({
  baseURL: '/api', // The vite proxy will handle this
  withCredentials: true, // Important for sending session cookies
});

axiosClient.interceptors.response.use(
  (response) => response.data,
  (error) => {
    // Return a structured error
    return Promise.reject(
      error.response?.data || { error: 'An unexpected error occurred' }
    );
  }
);

export default axiosClient;
