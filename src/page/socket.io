import Peer from 'peerjs';
import React, { useEffect, useRef, useState } from 'react';
import "./style/chat.css";

function Chat() {
  const [peerId, setPeerId] = useState('');
  const [connectedPeerId, setConnectedPeerId] = useState('');
  const [messages, setMessages] = useState([]);
  const [message, setMessage] = useState('');
  const [image, setImage] = useState(null); // State for the selected image
  const peerRef = useRef(null);

  useEffect(() => {
    peerRef.current = new Peer();

    const peer = peerRef.current;

    peer.on('open', (id) => {
      setPeerId(id);
      console.log('My peer ID:', id);
    });

    peer.on('connection', (conn) => {
      conn.on('data', (data) => {
        // Check if data is an image (base64 string or Blob)
        if (data.type === 'image') {
          setMessages((prevMessages) => [
            ...prevMessages,
            { type: 'image', content: data.content },
          ]);
        } else {
          setMessages((prevMessages) => [...prevMessages, data]);
        }
      });

      conn.on('open', () => {
        conn.send('user connect' + peerId);
      });
    });

    return () => {
      peer.destroy();
    };
  }, []);

  const connectToPeer = () => {
    const peer = peerRef.current;
    const conn = peer.connect(connectedPeerId);

    conn.on('open', () => {
      // Send text message if available
      if (message) {
        conn.send(message);
        setMessages((prevMessages) => [...prevMessages, `You: ${message}`]);
        setMessage('');
      }

      // Send image if available
      if (image) {
        const reader = new FileReader();
        reader.onload = () => {
          const imageData = reader.result;
          conn.send({ type: 'image', content: imageData });
          setMessages((prevMessages) => [
            ...prevMessages,
            { type: 'image', content: imageData },
          ]);
          setImage(null); // Reset image after sending
        };
        reader.readAsDataURL(image); // Convert image to base64 string
      }
    });

    conn.on('data', (data) => {
      if (data.type === 'image') {
        setMessages((prevMessages) => [
          ...prevMessages,
          { type: 'image', content: data.content },
        ]);
      } else {
        setMessages((prevMessages) => [...prevMessages, data]);
      }
    });
  };

  return (
    <div>
      <h1>P2P Messaging</h1>
      <div>
        <h2>Your Peer ID: {peerId}</h2>
        <input
          type="text"
          placeholder="Peer ID to connect"
          value={connectedPeerId}
          onChange={(e) => setConnectedPeerId(e.target.value)}
        />
        <button onClick={connectToPeer}>Connect</button>
      </div>
      <div>
        <h2>Messages</h2>
        <ul>
          {messages.map((msg, index) =>
            msg.type === 'image' ? (
              <li key={index}>
                <img src={msg.content}  alt="Received" width="200" />
                <a href={msg.content} className="btn" download> click</a>
              </li>
            ) : (
              <li key={index}>{msg}</li>
            )
          )}
        </ul>
      </div>
      <input
        type="text"
        value={message}
        onChange={(e) => setMessage(e.target.value)}
      />
      <input
        type="file"
        accept="image/*"
        onChange={(e) => setImage(e.target.files[0])}
      />
      <button onClick={connectToPeer}>Send</button>
    </div>
  );
}

export default Chat;
















//////// Adavance ImAGE upload ---------------------------------<><><><>

// import Peer from 'peerjs';
// import React, { useEffect, useRef, useState } from 'react';

// function Chat() {
//   const [peerId, setPeerId] = useState('');
//   const [connectedPeerId, setConnectedPeerId] = useState('');
//   const [messages, setMessages] = useState([]);
//   const [message, setMessage] = useState('');
//   const [file, setFile] = useState(null); // State to hold the selected file
//   const peerRef = useRef(null);

//   useEffect(() => {
//     // Create a new Peer instance
//     peerRef.current = new Peer(); // Peer generates a unique ID for you

//     const peer = peerRef.current;

//     // Get your own peer ID
//     peer.on('open', id => {
//       setPeerId(id);
//       console.log('My peer ID:', id);
//     });

//     // Handle incoming connections
//     peer.on('connection', conn => {
//       conn.on('data', data => {
//         if (data.type === 'file') {
//           // If the data is a file, render it as an image or link
//           setMessages(prevMessages => [
//             ...prevMessages,
//             { file: data.file, fileType: data.fileType, fileName: data.fileName }
//           ]);
//         } else {
//           // Otherwise, it's a text message
//           setMessages(prevMessages => [...prevMessages, { text: data }]);
//         }
//       });

//       conn.on('open', () => {
//         conn.send('Hello from ' + peerId);
//       });
//     });

//     // Cleanup on component unmount
//     return () => {
//       peer.destroy();
//     };
//   }, []);

//   const connectToPeer = () => {
//     const peer = peerRef.current;
//     const conn = peer.connect(connectedPeerId);

//     conn.on('open', () => {
//       if (file) {
//         const reader = new FileReader();
//         reader.onload = () => {
//           conn.send({
//             type: 'file',
//             file: reader.result, // Send base64 string
//             fileName: file.name,
//             fileType: file.type
//           });
//           setMessages(prevMessages => [
//             ...prevMessages,
//             { text: `You sent a file: ${file.name}`, file: reader.result, fileName: file.name, fileType: file.type }
//           ]);
//           setFile(null); // Clear the file input after sending
//         };
//         reader.readAsDataURL(file); // Convert file to base64
//       } else {
//         conn.send(message);
//         setMessages(prevMessages => [...prevMessages, { text: `You: ${message}` }]);
//         setMessage('');
//       }
//     });

//     conn.on('data', data => {
//       if (data.type === 'file') {
//         // Receive file
//         setMessages(prevMessages => [
//           ...prevMessages,
//           { file: data.file, fileName: data.fileName, fileType: data.fileType }
//         ]);
//       } else {
//         setMessages(prevMessages => [...prevMessages, { text: data }]);
//       }
//     });
//   };

//   const handleFileChange = e => {
//     setFile(e.target.files[0]);
//   };

//   return (
//     <div>
//       <h1>P2P Messaging with File Upload</h1>
//       <div>
//         <h2>Your Peer ID: {peerId}</h2>
//         <input
//           type="text"
//           placeholder="Peer ID to connect"
//           value={connectedPeerId}
//           onChange={e => setConnectedPeerId(e.target.value)}
//         />
//         <button onClick={connectToPeer}>Connect</button>
//       </div>
//       <div>
//         <h2>Messages</h2>
//         <ul>
//           {messages.map((msg, index) => (
//             <li key={index}>
//               {msg.file ? (
//                 msg.fileType && msg.fileType.startsWith('image/') ? (
//                   <img src={msg.file} alt="Received file" style={{ maxWidth: '400px' ,height:"100px" }} />
//                 ) : (
//                   <a href={msg.file} download={msg.fileName}>
//                     Download   dowmalod{msg.fileName}
//                   </a>
//                 )
//               ) : (
//                 msg.text
//               )}
//             </li>
//           ))}
//         </ul>
//       </div>
//       <input
//         type="text"
//         value={message}
//         onChange={e => setMessage(e.target.value)}
//         placeholder="Type your message"
//       />
//       <input type="file" onChange={handleFileChange} />
//       <button onClick={connectToPeer}>Send</button>
//     </div>
//   );
// }

// export default Chat;




// {/* <ul>
//   {messages.map((msg, index) => (
//     <li key={index}>
//       {msg.file ? (
//         msg.fileType && msg.fileType.startsWith('image/') ? (
//           <img src={msg.file} alt="Received file" style={{ maxWidth: '300px' }} />
//         ) : (
//           <a href={msg.file} download={msg.fileName}>
//             Download {msg.fileName}
//           </a>
//         )
//       ) : (
//         msg
//       )}
//     </li>
//   ))}
// </ul>

//  */}



/////////  simple chat app start up row call  ----  >>>

// import Peer from 'peerjs';
// import React, { useEffect, useRef, useState } from 'react';

// function Chat() {
//   const [peerId, setPeerId] = useState('');
//   const [connectedPeerId, setConnectedPeerId] = useState('');
//   const [messages, setMessages] = useState([]);
//   const [message, setMessage] = useState('');
//   const peerRef = useRef(null);

//   useEffect(() => {
//     // Create a new Peer instance
//     peerRef.current = new Peer(); // Peer generates a unique ID for you

//     const peer = peerRef.current;

//     // Get your own peer ID
//     peer.on('open', id => {
//       setPeerId(id);
//       console.log('My peer ID:', id);
//     });

//     // Handle incoming connections
//     peer.on('connection', conn => {
//       conn.on('data', data => {
//         setMessages(prevMessages => [...prevMessages, data]);
//       });

//       conn.on('open', () => {
//         conn.send('Hello from ' + peerId);
//       });
//     });

//     // Cleanup on component unmount
//     return () => {
//       peer.destroy();
//     };
//   }, []);

//   const connectToPeer = () => {
//     const peer = peerRef.current;
//     const conn = peer.connect(connectedPeerId);

//     conn.on('open', () => {
//       conn.send(message);
//       setMessages(prevMessages => [...prevMessages, `You: ${message}`]);
//       setMessage('');
//     });

//     conn.on('data', data => {
//       setMessages(prevMessages => [...prevMessages, data]);
//     });
//   };

//   return (
//     <div>
//       <h1>P2P Messaging</h1>
//       <div>
//         <h2>Your Peer ID: {peerId}</h2>
//         <input
//           type="text"
//           placeholder="Peer ID to connect"
//           value={connectedPeerId}
//           onChange={e => setConnectedPeerId(e.target.value)}
//         />



//         <button onClick={connectToPeer}>Connect</button>
//       </div>
//       <div>
//         <h2>Messages</h2>
//         <ul>
//           {messages.map((msg, index) => (
//             <li key={index}>{msg}</li>
//           ))}
//         </ul>
//       </div>
//       <input
//         type="text"
//         value={message}
//         onChange={e => setMessage(e.target.value)}
//       />
//       {/* <input type="file" name="" id="" /> add image and file upload options */}
//       <button onClick={connectToPeer}>Send</button>
//     </div>
//   );
// }

// export default Chat;


:::::::::::::::::::::::::::::::::::::::: Adsvance User Coonect :::::::::::::::::::::::::::::


import Peer from 'peerjs';
import React, { useEffect, useRef, useState } from 'react';
import "./style/chat.css";

function Chat() {
  const [peerId, setPeerId] = useState('');
  const [connectedPeerId, setConnectedPeerId] = useState('');
  const [messages, setMessages] = useState([]);
  const [message, setMessage] = useState('');
  const [image, setImage] = useState(null); // State for the selected image
  const [connectedPeers, setConnectedPeers] = useState([]); // State to track connected peers
  const peerRef = useRef(null);

  useEffect(() => {
    peerRef.current = new Peer();

    const peer = peerRef.current;

    peer.on('open', (id) => {
      setPeerId(id);
      console.log('My peer ID:', id);
    });

    peer.on('connection', (conn) => {
      // Add the connected peer to the state if not already added
      setConnectedPeers((prev) =>
        prev.includes(conn.peer) ? prev : [...prev, conn.peer]
      );

      conn.on('data', (data) => {
        // Check if data is an image (base64 string or Blob)
        if (data.type === 'image') {
          setMessages((prevMessages) => [
            ...prevMessages,
            { type: 'image', content: data.content },
          ]);
        } else {
          setMessages((prevMessages) => [...prevMessages, data]);
        }
      });

      conn.on('close', () => {
        // Remove the disconnected peer from the state
        setConnectedPeers((prev) => prev.filter((id) => id !== conn.peer));
      });

      conn.on('open', () => {
        conn.send('user connect' + peerId);
      });
    });

    return () => {
      peer.destroy();
    };
  }, []);

  const connectToPeer = () => {
    const peer = peerRef.current;
    const conn = peer.connect(connectedPeerId);

    conn.on('open', () => {
      // Add connected peer to the list if not already added
      setConnectedPeers((prev) =>
        prev.includes(connectedPeerId) ? prev : [...prev, connectedPeerId]
      );

      // Send text message if available
      if (message) {
        conn.send(message);
        setMessages((prevMessages) => [...prevMessages, `You: ${message}`]);
        setMessage('');
      }

      // Send image if available
      if (image) {
        const reader = new FileReader();
        reader.onload = () => {
          const imageData = reader.result;
          conn.send({ type: 'image', content: imageData });
          setMessages((prevMessages) => [
            ...prevMessages,
            { type: 'image', content: imageData },
          ]);
          setImage(null); // Reset image after sending
        };
        reader.readAsDataURL(image); // Convert image to base64 string
      }
    });

    conn.on('data', (data) => {
      if (data.type === 'image') {
        setMessages((prevMessages) => [
          ...prevMessages,
          { type: 'image', content: data.content },
        ]);
      } else {
        setMessages((prevMessages) => [...prevMessages, data]);
      }
    });

    conn.on('close', () => {
      // Remove the disconnected peer
      setConnectedPeers((prev) => prev.filter((id) => id !== connectedPeerId));
    });
  };

  return (
    <div>
      <h1>P2P Messaging</h1>
      <div>
        <h2>Your Peer ID: {peerId}</h2>
        <input
          type="text"
          placeholder="Peer ID to connect"
          value={connectedPeerId}
          onChange={(e) => setConnectedPeerId(e.target.value)}
        />
        <button onClick={connectToPeer}>Connect</button>
      </div>
      <div>
        <h2>Connected Users ({connectedPeers.length})</h2> {/* Display the number of connected peers */}
        <ul>
          {connectedPeers.map((id, index) => (
            <li key={index}>
              <span
                style={{
                  display: 'inline-block',
                  width: '10px',
                  height: '10px',
                  backgroundColor: 'green',
                  borderRadius: '50%',
                  marginRight: '10px',
                }}
              ></span>
              {id}
            </li>
          ))}
        </ul>
      </div>
      <div>
        <h2>Messages</h2>
        <ul>
          {messages.map((msg, index) =>
            msg.type === 'image' ? (
              <li key={index}>
                <img src={msg.content} alt="Received" width="200" />
                <a href={msg.content} className="btn" download>
                  Download
                </a>
              </li>
            ) : (
              <li key={index}>{msg}</li>
            )
          )}
        </ul>
      </div>
      <input
        type="text"
        value={message}
        onChange={(e) => setMessage(e.target.value)}
      />
      <input
        type="file"
        accept="image/*"
        onChange={(e) => setImage(e.target.files[0])}
      />
      <button onClick={connectToPeer}>Send</button>
    </div>
  );
}

export default Chat;
