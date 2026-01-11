// API Client for RV Marketplace
const API = {
  baseURL: window.location.origin,
  token: localStorage.getItem('auth_token'),

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    const response = await fetch(url, {
      ...options,
      headers
    });

    if (response.status === 401) {
      this.logout();
      window.location.href = '/login';
      return;
    }

    return response.json();
  },

  async get(endpoint) {
    return this.request(endpoint, { method: 'GET' });
  },

  async post(endpoint, data) {
    return this.request(endpoint, {
      method: 'POST',
      body: JSON.stringify(data)
    });
  },

  async put(endpoint, data) {
    return this.request(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data)
    });
  },

  async delete(endpoint) {
    return this.request(endpoint, { method: 'DELETE' });
  },

  setToken(token) {
    this.token = token;
    localStorage.setItem('auth_token', token);
  },

  logout() {
    this.token = null;
    localStorage.removeItem('auth_token');
  }
};

// Authentication
async function login(email, password) {
  try {
    const response = await API.post('/authenticate/token', { email, password });
    if (response.token) {
      API.setToken(response.token);
      updateAuthUI();
      return true;
    }
    return false;
  } catch (error) {
    console.error('Login error:', error);
    return false;
  }
}

async function signup(name, email, password, passwordConfirmation) {
  try {
    const response = await API.post('/authenticate/sign_up', {
      name,
      email,
      password,
      password_confirmation: passwordConfirmation
    });
    if (response.token) {
      API.setToken(response.token);
      updateAuthUI();
      return true;
    }
    return false;
  } catch (error) {
    console.error('Signup error:', error);
    return false;
  }
}

function logout() {
  API.logout();
  updateAuthUI();
  window.location.href = '/';
}

function updateAuthUI() {
  const token = API.token;
  const logoutBtn = document.getElementById('logout-btn');
  const loginLink = document.getElementById('login-link');
  const userEmail = document.getElementById('user-email');

  if (token) {
    if (logoutBtn) logoutBtn.classList.remove('hidden');
    if (loginLink) loginLink.classList.add('hidden');
    // Note: In a real app, you'd fetch user info from an endpoint
    if (userEmail) userEmail.textContent = 'User';
  } else {
    if (logoutBtn) logoutBtn.classList.add('hidden');
    if (loginLink) loginLink.classList.remove('hidden');
    if (userEmail) userEmail.textContent = '';
  }
}

// Initialize auth UI on page load
document.addEventListener('DOMContentLoaded', () => {
  updateAuthUI();
});
