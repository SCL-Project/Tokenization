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
    Form,
} from './SignUpElements';

const SignUp = () => {
  return (
    <>
        <Container>
            <FormWrap>
                <Icon to="/">P2P-Lending</Icon> 
                <FormContent>
                    <Form action="#">
                        <FormH1>REGISTER</FormH1>

                        <FormLable htmlFor="name">Name</FormLable>
                        <FormInput type="text" id="name" name="name" required />

                        <FormLable htmlFor="surname">Surname</FormLable>
                        <FormInput type="text" id="surname" name="surname" required />

                        <FormLable htmlFor="date-of-birth">Date of Birth</FormLable>
                        <FormInput type="date" id="date-of-birth" name="date-of-birth" required />

                        <FormLable htmlFor="email">Email</FormLable>
                        <FormInput type="email" id="email" name="email" required />

                        <FormLable htmlFor="address">Address</FormLable>
                        <FormInput type="text" id="address" name="address" required />

                        <FormLable htmlFor="city">City</FormLable>
                        <FormInput type="text" id="city" name="city" required />

                        <FormLable htmlFor="pzl">PLZ</FormLable>
                        <FormInput type="text" id="pzl" name="pzl" required />

                        <FormLable htmlFor="wallet-address">Wallet-Address</FormLable>
                        <FormInput type="text" id="wallet-address" name="wallet-address" required />

                        <FormLable htmlFor="ahv-number">AHV Number</FormLable>
                        <FormInput type="text" id="ahv-number" name="ahv-number" required />

                        <FormButton type='submit'>Continue</FormButton>
                    </Form>
                </FormContent>
            </FormWrap>
        </Container>
    </>
  )
}

export default SignUp;