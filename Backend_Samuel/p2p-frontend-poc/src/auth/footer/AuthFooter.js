import React from "react";
import { Container } from "react-bootstrap";

const AuthFooter = () => {
    return (
        <React.Fragment>
            <footer className="bg-light border-top py-3 fixed-bottom">
                <Container>
                    &copy; P2P Lending - 2024
                </Container>
            </footer>
        </React.Fragment>
    );
}

export default AuthFooter;