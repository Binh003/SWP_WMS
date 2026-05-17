import { http } from './http'

export async function listRolesApi() {
  const res = await http.get('/api/roles')
  return res.data
}

export async function getRoleApi(roleId) {
  const res = await http.get(`/api/roles/${roleId}`)
  return res.data
}

export async function listPermissionsApi() {
  const res = await http.get('/api/permissions')
  return res.data
}

export async function setRolePermissionsApi(roleId, permissionCodes) {
  const res = await http.put(`/api/roles/${roleId}/permissions`, { permissionCodes })
  return res.data
}
