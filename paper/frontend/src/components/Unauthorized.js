import Link from 'next/link';
import styles from '../styles/Unauthorized.module.css';

const Unauthorized = () => {
    return (
        <div className={styles.center}>
            <h1>UNAUTHORIZED</h1>
            <Link href={`/investors`}>
                <p>please visit the investors page</p>
            </Link>
        </div>
    );
}

export default Unauthorized;