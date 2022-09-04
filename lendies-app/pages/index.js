import styles from "../styles/Home.module.css";
import {
    Box,
    Button,
    Divider,
    Flex,
    Heading,
    Img,
    Text,
    VStack,
} from "@chakra-ui/react";

export default function Home() {
    return (
        <VStack>
            <Text
                border={"8px"}
                borderRadius={"3xl"}
                p={6}
                textStyle={"h1"}
                font={"logo"}
            >
                lendies
            </Text>
            <Text textStyle={"h2"} p={6} pb={52}>
                A decentralized lending protocol
            </Text>

            <VStack
                borderTop={"4px"}
                borderBottom={"4px"}
                borderRadius={"xl"}
                borderColor={"blue.200"}
                p={"8"}
            >
                <Text textStyle={"h3"} p={3}>
                    Opening the world of lending, credibility and opportunity!
                </Text>
                <Button border={"2px"} p={3} colorScheme={"blue"}>
                    Learn More!
                </Button>
            </VStack>

            <main className={styles.main}>
                <div className={styles.grid}>
                    <a href="#" className={styles.card}>
                        <h2>Documentation &rarr;</h2>
                        <p>
                            Lorem ipsum dolor sit amet, consectetur adipiscing
                            elit.
                        </p>
                    </a>
                    <a href="#" className={styles.card}>
                        <h2>Learn &rarr;</h2>
                        <p>
                            Lorem ipsum dolor sit amet, consectetur adipiscing
                            elit.
                        </p>
                    </a>
                    <a href="#" className={styles.card}>
                        <h2>Examples &rarr;</h2>
                        <p>
                            Lorem ipsum dolor sit amet, consectetur adipiscing
                            elit.
                        </p>
                    </a>
                    <a href="#" className={styles.card}>
                        <h2>Deploy &rarr;</h2>
                        <p>
                            Lorem ipsum dolor sit amet, consectetur adipiscing
                            elit.
                        </p>
                    </a>
                </div>
            </main>

            <footer className={styles.footer}>
                Powered by <Text>lendies</Text>
            </footer>
        </VStack>
    );
}
