import React from 'react'
import { 
    Container, 
    FormContent, 
    FormLable,
    FormWrap,
    FormH1,
    FormInput,
    FormButton,
    Text,
    Form,
} from './LoginElements';

const LogIn = () => {
  return (
    <>
        <Container>
            <FormWrap>
                <FormContent>
                    <Form action="#">
                        <FormH1>Log in to your account</FormH1>
                        <FormLable htmlFor='for'>Email</FormLable>
                        <FormInput type='email' required />
                        <FormLable htmlFor = 'for'>Password</FormLable>
                        <FormInput type='password' required />
                        <FormButton to='/Marketplace' type='submit'>Continue</FormButton>
                        <Text>Forgot password</Text>
                    </Form>
                </FormContent>
            </FormWrap>
        </Container>
    </>
  )
}

export default LogIn;