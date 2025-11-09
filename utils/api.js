// API 配置
// 优先使用环境变量，否则使用相对路径（通过 nginx 代理）
const API_BASE_URL = process.env.VUE_APP_API_BASE_URL || 
  (typeof window !== 'undefined' ? window.location.origin : 'http://localhost:3000');

export default {
  baseURL: API_BASE_URL,
  getContacts: () => `${API_BASE_URL}/contacts`,
  addContact: () => `${API_BASE_URL}/contacts`,
  deleteContact: (id) => `${API_BASE_URL}/contacts/${id}`,
  updateContact: (id) => `${API_BASE_URL}/contacts/${id}`,
  uploadAvatar: () => `${API_BASE_URL}/upload`,
};


