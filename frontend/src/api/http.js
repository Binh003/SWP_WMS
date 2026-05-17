import axios from 'axios'
import { getAccessToken } from '../auth/token'

export const http = axios.create({
  baseURL: '/',
})

http.interceptors.request.use((config) => {
  const token = getAccessToken()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})
