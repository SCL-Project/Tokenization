import axios from "axios";
import React, { useState } from "react";
import { Button, Col, Container, Form, FormGroup, FormLabel, Row } from "react-bootstrap";
import { useNavigate } from "react-router-dom";

const Register = () => {
    const registerAPI = 'http://localhost:4000/register';
    const navigate = useNavigate();
    const [formData, setFormData] = useState({
        email: '',
        password: '',
        firstname: '',
        lastname: ''
    });

    const handleChange = (event) => {
        const { name, value } = event.target;
        setFormData({ ...formData, [name]: value });
    }

    const submitRegisterForm = (event) => {
        event.preventDefault();
        const btnPointer = document.querySelector('#register-btn');
        btnPointer.innerHTML = 'Please wait..';
        btnPointer.setAttribute('disabled', true);

        axios.post(registerAPI, formData)
            .then(() => {
                btnPointer.innerHTML = 'Register';
                btnPointer.removeAttribute('disabled');
                setTimeout(() => {
                    navigate('/auth/login');
                }, 500);
            })
            .catch((error) => {
                btnPointer.innerHTML = 'Register';
                btnPointer.removeAttribute('disabled');
                alert("Oops! Some error occurred.");
                console.error('Registration error:', error);
            });
    }

    return (
        <React.Fragment>
            <Container className="my-5">
                <h2 className="fw-normal mb-5">Register to P2P Lending</h2>
                <Row>
                    <Col md={{ span: 6 }}>
                        <Form onSubmit={submitRegisterForm}>
                            <FormGroup className="mb-3">
                                <FormLabel htmlFor={'register-email'}>Email Address</FormLabel>
                                <input type={'email'} className="form-control" id={'register-email'} name="email" value={formData.email} onChange={handleChange} required />
                            </FormGroup>
                            <FormGroup className="mb-3">
                                <FormLabel htmlFor={'register-firstname'}>First Name</FormLabel>
                                <input type={'text'} className="form-control" id={'register-firstname'} name="firstname" value={formData.firstname} onChange={handleChange} required />
                            </FormGroup>
                            <FormGroup className="mb-3">
                                <FormLabel htmlFor={'register-lastname'}>Last Name</FormLabel>
                                <input type={'text'} className="form-control" id={'register-lastname'} name="lastname" value={formData.lastname} onChange={handleChange} required />
                            </FormGroup>
                            <FormGroup className="mb-3">
                                <FormLabel htmlFor={'register-password'}>Password</FormLabel>
                                <input type={'password'} className="form-control" id={'register-password'} name="password" value={formData.password} onChange={handleChange} required />
                            </FormGroup>
                            <Button type="submit" className="btn-success mt-2" id="register-btn">Register</Button>
                        </Form>
                    </Col>
                </Row>
            </Container>
        </React.Fragment>
    );
}

export default Register;
