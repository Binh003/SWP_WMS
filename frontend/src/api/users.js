import { http } from './http'

export async function listUsersApi() {
  const res = await http.get('/api/users')
  return res.data
}

export async function getUserApi(userId) {
  const res = await http.get(`/api/users/${userId}`)
  return res.data
}

export async function createUserApi(payload) {
  const res = await http.post('/api/users', payload)
  return res.data
}

export async function updateUserApi(userId, payload) {
  const res = await http.put(`/api/users/${userId}`, payload)
  return res.data
}

export async function setUserRolesApi(userId, roleCodes) {
  const res = await http.put(`/api/users/${userId}/roles`, { roleCodes })
  return res.data
}

export async function setUserEnabledApi(userId, enabled) {
  const res = await http.put(`/api/users/${userId}/enabled`, null, {
    params: { enabled },
  })
  return res.data
}
