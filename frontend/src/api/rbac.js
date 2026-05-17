import { http } from './http'

export async function listRolesApi() {
  const res = await http.get('/api/roles')
  return res.data
}

export async function getRoleApi(roleId) {
  const res = await http.get(`/api/roles/${roleId}`)
  return res.data
}


