import axios from "axios";
import localStorageService from "./localStorageService";

class JwtAuthService {

  loginWithEmailAndPassword = (email, password) => {
    return axios.post("/login",{username:email,password:password}).then(data => {
      this.setSession(data.data.data.token);
      this.setUser(data.data.data);
      console.log(data);
      return data.data;
    });
  };

  loginWithToken = async () => {
    const jwt = localStorage.getItem("jwt_token");
    try {
      const data = await axios.get("/login_with_token", {headers: {'Authorization': "Bearer " + jwt}})
      this.setSession(data.data.data.token);
      this.setUser(data.data.data);
      console.log(data);
      return data.data;
    } catch (e) {
      console.log(e);
      this.logout()
    }
  };


  logout = () => {
    this.setSession(null);
    this.removeUser();
  };

  // Set token to all http request header, so you don't need to attach everytime
  setSession = token => {
    if (token) {
      localStorage.setItem("jwt_token", token);
      axios.defaults.headers.common["Authorization"] = "Bearer " + token;
    } else {
      localStorage.removeItem("jwt_token");
      delete axios.defaults.headers.common["Authorization"];
    }
  };

  // Save user to localstorage
  setUser = (user) => {
    localStorageService.setItem("auth_user", user);
  };
  // Remove user from localstorage
  removeUser = () => {
    localStorage.removeItem("auth_user");
  };
}

export default new JwtAuthService();
