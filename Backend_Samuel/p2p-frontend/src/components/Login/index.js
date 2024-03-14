import React, { useState, useContext } from 'react';
import axios from "axios";
import { AuthContext } from "./../AuthContext";
import { useNavigate } from "react-router-dom";
import { 
    Container, 
    FormContent, 
    FormLable,
    FormWrap,
    Icon,
    FormH1,
    FormInput,
    FormButton,
    Text,
    Form,
} from './LoginElements';



const LogIn = () => {

    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [errorMessage, setErrorMessage] = useState(null); // New state for handling error messages
    const { setToken } = useContext(AuthContext);
    const navigate = useNavigate();
    const handleSubmit = async (e) => {
    e.preventDefault();
    try {
        const response = await axios.post("http://localhost:3001/login", {
        email,
        password,
        });
        setToken(response.data.token);
        localStorage.setItem("token", response.data.token);
        navigate("/Marketplace");
    } catch (error) {
        console.error("Authentication failed:", error);
        setToken(null);
        localStorage.removeItem("token");
        if (error.response && error.response.data) {
        setErrorMessage(error.response.data); // Set the error message if present in the error response
        } else {
        setErrorMessage("An unexpected error occurred. Please try again.");
        }
    }
    };
            
  return (
    <>
        <Container>
            <FormWrap>
                <Icon to="/">P2P-Lending</Icon> 
                <FormContent>
                    {errorMessage && <div style={{ color: "red" }}>{errorMessage}</div>}{" "}
                    <Form onSubmit={handleSubmit}>
                        <FormH1>Log in to your account</FormH1>
                        <FormLable htmlFor='for'>Email</FormLable>
                        <FormInput 
                            type='email' 
                            required 
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                        />
                        <FormLable htmlFor = 'for'>Password</FormLable>
                        <FormInput 
                            type='password' 
                            required 
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                        />
                        <FormButton to='/Marketplace' type='submit'>Continue</FormButton>
                        <Text>Forgot password</Text>
                    </Form>
                </FormContent>
            </FormWrap>
        </Container>
    </>
  );
};

export default LogIn;
