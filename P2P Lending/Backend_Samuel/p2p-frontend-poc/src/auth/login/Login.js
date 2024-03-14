import axios from "axios";
import React from "react";
import { Button, Col, Container, Form, FormGroup, FormLabel, Row } from "react-bootstrap";
import { useNavigate } from "react-router-dom";

const Login = () => {

    const loginAPI = 'http://localhost:4000/login';
    const navigate = useNavigate();

    const submitLoginForm = (event) => {
        event.preventDefault();
        const formElement = document.querySelector('#loginForm');
        const formData = new FormData(formElement);
        const formDataJSON = Object.fromEntries(formData);
        const btnPointer = document.querySelector('#login-btn');
        btnPointer.innerHTML = 'Please wait..';
        btnPointer.setAttribute('disabled', true);
        axios.post(loginAPI, formDataJSON).then((response) => {
            btnPointer.innerHTML = 'Login';
            btnPointer.removeAttribute('disabled');
            const data = response.data;
            const token = data.token;
            if (!token) {
                alert('Unable to login. Please try after some time.');
                return;
            }
            localStorage.clear();
            localStorage.setItem('user-token', token);
            setTimeout(() => {
                navigate('/');
            }, 500);

        }).catch((error) => {
            btnPointer.innerHTML = 'Login';
            btnPointer.removeAttribute('disabled');
            alert("Oops! Some error occured.");
        });
    }

    return (
        <React.Fragment>
            <Container className="my-5">
                <h2 className="fw-normal mb-5">Login To P2P Lending</h2>
                <Row>
                    <Col md={{span: 6}}>
                        <Form id="loginForm" onSubmit={submitLoginForm}>
                            <FormGroup className="mb-3">
                                <FormLabel htmlFor={'login-email'}>Email Adress</FormLabel>
                                <input type={'text'} className="form-control" id={'login-email'} name="email" required />
                            </FormGroup>
                            <FormGroup className="mb-3">
                                <FormLabel htmlFor={'login-password'}>Password</FormLabel>
                                <input type={'password'} className="form-control" id={'login-password'} name="password" required />
                            </FormGroup>
                            <Button type="submit" className="btn-success mt-2" id="login-btn">Login</Button>
                        </Form>
                    </Col>
                </Row>
            </Container>
        </React.Fragment>
    );
}

export default Login;