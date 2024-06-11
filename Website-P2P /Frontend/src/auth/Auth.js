import React from "react";
import { Outlet } from "react-router-dom";
import AuthFooter from "./auth.elements/footer/AuthFooter";
import AuthNavbar from "./auth.elements/navbar/AuthNavbar";

const Auth = () => {
    return (
        <React.Fragment>
            <AuthNavbar />
            <Outlet />
            <AuthFooter />
        </React.Fragment>
    );
}

export default Auth;