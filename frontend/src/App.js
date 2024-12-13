import React, { useState, useEffect } from 'react';
import axios from 'axios';

function App() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');
  const [messageToSent, setMessageToSent] = useState('');
  const [usernameReciever, setReciever] = useState('');
  const [isTokenPresent, setIsTokenPresent] = useState(false);
  const [messages, setMessages] = useState([]);  

  useEffect(() => {
    // Sprawdzamy, czy accessToken jest w localStorage
    const token = localStorage.getItem('accessToken');
    if (token) {
      setIsTokenPresent(true); // Ustawiamy stan, aby przycisk był widoczny
    }
  }, []);

  const handleSignup = async () => {
    try {
      const response = await axios.post(`/signup`,
        {
          username,
          password,
          email
        },
        {
          headers: {
            'Content-Type': 'application/json'
          }
        }
      );

      console.log('User signed up:', username);
      console.log(response.data);
      setMessage('Signup successful!');
      } catch (error) {
        console.log(`Error during signup: ${error.message}`);
        setMessage(`Error during signup: ${error.response.data.error}`);
      }
  };

  const handleLogin = async () => {
    try {
      const response = await axios.post(`/login`,
        {
          username,
          password
        },
        {
          headers: {
            'Content-Type': 'application/json'
          }
        }
      );

      console.log('User login:', username);
      console.log(response.data);
      setMessage('Logged successful!');
      localStorage.setItem('accessToken', response.data.AccessToken);
      localStorage.setItem('refreshToken', response.data.RefreshToken);
      //refreshTokenFun();
      } catch (error) {
        console.log(`Error during signup: ${error.message}`);
        setMessage(`Error during signup: ${error.response.data.error}`);
      }
  };

  const handleLogout = async () => {
    if (!localStorage.getItem('accessToken')) {
      setMessage('No user logged in');
      return;
    }
    try {
      const authorization = localStorage.getItem('accessToken');
      console.log(authorization)
      const response = await axios.post(`/logout`,
        {
          authorization
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${authorization}`
          }
        }
      );
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      setMessage('Logged out successfully');
      console.log(response.data);
    } catch (error) {
      setMessage(`Logout failed: ${error.response.data.error}`);
    }
  };

  const refreshTokenFun = async () =>  {

    try {
      const refreshToken = localStorage.getItem('refreshToken');
      const response = await axios.post(`/refresh_token`,
        {
          refreshToken
        },
        {
          headers: {
            'Content-Type': 'application/json'
          }
        }
      );

      console.log('Access token refreshed!');
      console.log(response.data);
      localStorage.setItem('accessToken', response.data.AccessToken);
      localStorage.setItem('refreshToken', response.data.RefreshToken);
      setTimeout(refreshTokenFun, (response.data.ExpiresIn - 280) * 1000);

    } catch (error) {
      setMessage(`Could not refresh token: ${error.response.data.error}`);
    }
  };

  const handleFetchingUsers = async () => {
    if (!localStorage.getItem('accessToken')) {
      setMessage('You must log in to fetch user list');
      return;
    }
    try {
      const authorization = localStorage.getItem('accessToken');
      console.log(authorization)
      const response = await axios.get(`/users`,
        {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${authorization}`
          }
        }
      );
      if (response.data && response.data.UsernameList) {
        setMessage(JSON.stringify(response.data.UsernameList, null, 2));
      } else {
        setMessage('No users found.');
      }
    } catch (error) {
      setMessage(`Fetching users failed: ${error.response.data.error}`);
    }
  };

  const handleFetchingSentMesseges = async () => {
    if (!localStorage.getItem('accessToken')) {
      setMessage('You must log in to fetch user list');
      return;
    }
    try {
      const authorization = localStorage.getItem('accessToken');
      console.log(authorization)
      const response = await axios.get(`/get_sent_messages`,
        {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${authorization}`
          }
        }
      );
      if (response.data) {
        console.log(response.data.messages)
        setMessages(response.data.messages);
        setMessage('Messages fetched successfully');
      } else {
        setMessage('No sent messeges found.');
      }
    } catch (error) {
      if (error.response) {
        setMessage(`Fetching sent messages failed: ${error.response.data.error}`);
      } else {
        setMessage(`Fetching sent messages failed: ${error}`);
      }
    }
  };

  const handleFetchingRecivedMesseges = async () => {
    if (!localStorage.getItem('accessToken')) {
      setMessage('You must log in to fetch user list');
      return;
    }
    try {
      const authorization = localStorage.getItem('accessToken');
      console.log(authorization)
      const response = await axios.get(`/get_recieved_messages`,
        {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${authorization}`
          }
        }
      );
      if (response.data) {
        console.log(response.data.messages)
        setMessages(response.data.messages);
        setMessage('Messages fetched successfully');
      } else {
        setMessage('No recived messeges found.');
      }
    } catch (error) {
      if (error.response) {
        setMessage(`Fetching recived messages failed: ${error.response.data.error}`);
      } else {
        setMessage(`Fetching recived messages failed: ${error}`);
      }
    }
  };


  const handleSendingMessage = async () => {
    if (!localStorage.getItem('accessToken')) {
      setMessage('You must log in to fetch user list');
      return;
    }
    try {
      const authorization = localStorage.getItem('accessToken');
      console.log(authorization)
      const response = await axios.post(`/send_message`,
        {
          messageToSent,
          usernameReciever
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${authorization}`
          }
        }
      );
      setMessage('Sent Message successfully');
      console.log(response.data);
    } catch (error) {
      setMessage(`Fetching recived messages failed: ${error.response.data.error}`);
    }
  };

  return (
    <div className="App">
      <h1>App</h1>
      <div id="auth-section">
            <form id="login-form">
                <input type="text" id="login-username" placeholder="Username" onChange={(e) => setUsername(e.target.value)}></input>
                <input type="password" id="login-password" placeholder="Password" onChange={(e) => setPassword(e.target.value)}></input>
                <button type="button" onClick={handleLogin}>Log In</button>
            </form>
            <form id="signup-form">
                <input type="text" id="signup-username" placeholder="Username" onChange={(e) => setUsername(e.target.value)}></input>
                <input type="password" id="signup-password" placeholder="Password" onChange={(e) => setPassword(e.target.value)}></input>
                <input type="email" id="signup-email" placeholder="Email" onChange={(e) => setEmail(e.target.value)}></input>
                <button type="button" onClick={handleSignup}>Sign Up</button>
            </form>
            <button type="button" onClick={handleLogout}>Log Out</button>
            <div>
              {isTokenPresent && (
                <React.Fragment>
                  <form id="message-form">
                      <input type="text" id="message" placeholder="message" onChange={(e) => setMessageToSent(e.target.value)}></input>
                      <input type="text" id="message_reciever" placeholder="reciever" onChange={(e) => setReciever(e.target.value)}></input>
                      <button type="button" onClick={handleSendingMessage}>Sent Message</button>
                  </form>
                  <button type="button" onClick={handleFetchingUsers}>List of Users</button>
                  <button type="button" onClick={handleFetchingSentMesseges}>List of sent messages</button>
                  <button type="button" onClick={handleFetchingRecivedMesseges}>List of recived messages</button>

                  <ul>
                    {messages.length > 0 ? (
                      messages.map(([msg, user, date], index) => (
                        <li key={index}>
                          <strong>Message:</strong> {msg} <br />
                          <strong>User:</strong> {user} <br />
                          <strong>Date:</strong> {date}
                        </li>
                      ))
                    ) : (
                      <p>No messages to display.</p>
                    )}
                  </ul>
                </React.Fragment>
              )}
            </div>
        </div>
      <p>{message}</p>
    </div>
  );
}

export default App;