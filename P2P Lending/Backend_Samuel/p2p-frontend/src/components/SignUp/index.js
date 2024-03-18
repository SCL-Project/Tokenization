import React, { useState } from "react";
import axios from "axios";
import { 
    Container, 
    FormContent, 
    FormLable,
    FormWrap,
    Icon,
    FormH1,
    FormInput,
    FormButton,
    Form,
} from './SignUpElements';

const SignUp = () => {

    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [message, setMessage] = useState("");

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
        const response = await axios.post("http://localhost:3001/register", {
            email,
            password,
        });
        setMessage(response.data.message);
        } catch (error) {
        console.error("Registration failed:", error.response.data.error);
        setMessage(error.response.data.error);
        }
    };


  return (
    <>
        <Container>
            <FormWrap>
                <Icon to="/">P2P-Lending</Icon> 
                <FormContent>
                    <Form onSubmit={handleSubmit}>
                        <FormH1>REGISTER</FormH1>

                        <FormLable htmlFor="email">Email</FormLable>
                        <FormInput 
                            type="email" 
                            id="email" 
                            name="email" 
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            required />

                        <FormLable htmlFor="password">Password</FormLable>
                        <FormInput 
                            type="password" 
                            id="password" 
                            name="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required />

                        <FormButton type='submit'>Continue</FormButton>
                    </Form>
                    {message && <p>{message}</p>}
                </FormContent>
            </FormWrap>
        </Container>
    </>
  )
}

export default SignUp;
