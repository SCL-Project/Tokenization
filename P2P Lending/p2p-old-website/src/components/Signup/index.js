import React from 'react'
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
} from './SignupElements';

const SignUp = () => {
  return (
    <>
        <Container>
            <FormWrap>
                <Icon to="/">P2P-Lending</Icon> 
                <FormContent>
                    <Form action="#">
                        <FormH1>Register</FormH1>
                        <FormLable htmlFor='for'>Surname</FormLable>
                        <FormInput type='text' required />
                        <FormLable htmlFor='for'>Lastname</FormLable>
                        <FormInput type='text' required />
                        <FormLable htmlFor='for'>Email</FormLable>
                        <FormInput type='email' required />
                        <FormLable htmlFor='for'>Address</FormLable>
                        <FormInput type='text' required />
                        <FormLable htmlFor='for'>City</FormLable>
                        <FormInput type='text' required />
                        <FormLable htmlFor='for'>PLZ</FormLable>
                        <FormInput type='number' required />
                        <FormLable htmlFor='for'>Date of birth</FormLable>
                        <FormInput type='number' required />
                        <FormLable htmlFor='for'>Walletaddress</FormLable>
                        <FormInput type='text' required />
                        <FormButton type='submit'>Sign Up</FormButton>
                        <Text>Forgot password</Text>
                    </Form>
                </FormContent>
            </FormWrap>
        </Container>
    </>
  )
}

export default SignUp;