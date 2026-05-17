import { http } from './http'

export async function loginApi(payload) {
  const res = await http.post('/api/auth/login', payload)
  return res.data
}

export async function meApi() {
  const res = await http.get('/api/auth/me')
  return res.data
}

export async function logoutApi() {
  const res = await http.post('/api/auth/logout')
  return res.data
}

export async function registerApi(payload) {
  const res = await http.post('/api/auth/register', payload)
  return res.data
}

export async function changePasswordApi(payload) {
  const res = await http.post('/api/auth/change-password', payload)
  return res.data
}

export async function forgotPasswordApi(payload) {
  const res = await http.post('/api/auth/forgot-password', payload)
  return res.data
}

export async function resetPasswordApi(payload) {
  const res = await http.post('/api/auth/reset-password', payload)
  return res.data
}
