import "../styles/globals.css";

import { ChakraProvider } from "@chakra-ui/react";
import MainNavigation from '../components/MainNavigation'
import { Web3ReactProvider } from '@web3-react/core'
import { ethers } from 'ethers';
import theme from "../styles/theme";
import '@fontsource/raleway/400.css'
import '@fontsource/open-sans/700.css'
import '@fontsource/kanit/900.css'

const getLibrary = (provider) => {
    const library = new ethers.providers.Web3Provider(provider);
    library.pollingInterval = 8000; // frequency provider is polling
    return library;
};

function MyApp({ Component, pageProps }) {
    return (

        <ChakraProvider theme={theme}>
            <Web3ReactProvider getLibrary={getLibrary}>
                <header>
                    <title>lendies</title>
                    <meta name="lendies" content="lendies" />
                    <link rel="icon" href="/favicon.ico" />
                </header>
                <MainNavigation />
                <Component {...pageProps} />
            </Web3ReactProvider>
        </ChakraProvider>
    );
}

export default MyApp;
