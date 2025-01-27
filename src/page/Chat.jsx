import Peer from "peerjs";
import React, { useEffect, useRef, useState } from "react";
import "./style/chat.css";

function Chat() {
  const [peerId, setPeerId] = useState("");
  const [connectedPeerId, setConnectedPeerId] = useState("");
  const [messages, setMessages] = useState([]);
  const [message, setMessage] = useState("");
  const [file, setFile] = useState(null); // State for the selected file (image/video/other)
  const [connectedPeers, setConnectedPeers] = useState([]);
  const peerRef = useRef(null);

  useEffect(() => {
    peerRef.current = new Peer();

    const peer = peerRef.current;

    peer.on("open", (id) => {
      setPeerId(id);
      console.log("My peer ID:", id);
    });

    peer.on("connection", (conn) => {
      setConnectedPeers((prev) =>
        prev.includes(conn.peer) ? prev : [...prev, conn.peer]
      );

      conn.on("data", (data) => {
        if (data.type === "file") {
          setMessages((prevMessages) => [
            ...prevMessages,
            { type: "file", content: data.content, fileName: data.fileName },
          ]);
        } else if (data.type === "text") {
          setMessages((prevMessages) => [...prevMessages, data.content]);
        }
      });

      conn.on("close", () => {
        setConnectedPeers((prev) => prev.filter((id) => id !== conn.peer));
      });

      conn.on("open", () => {
        conn.send(`User connected: ${peerId}`);
      });
    });

    return () => {
      peer.destroy();
    };
  }, []);

  const connectToPeer = () => {
    const peer = peerRef.current;
    const conn = peer.connect(connectedPeerId);

    conn.on("open", () => {
      setConnectedPeers((prev) =>
        prev.includes(connectedPeerId) ? prev : [...prev, connectedPeerId]
      );

      if (message) {
        conn.send({ type: "text", content: message });
        setMessages((prevMessages) => [...prevMessages, `You: ${message}`]);
        setMessage("");
      }

      if (file) {
        const reader = new FileReader();
        reader.onload = () => {
          const fileData = reader.result;
          conn.send({
            type: "file",
            content: fileData,
            fileName: file.name,
          });
          setMessages((prevMessages) => [
            ...prevMessages,
            { type: "file", content: fileData, fileName: file.name },
          ]);
          setFile(null);
        };
        reader.readAsDataURL(file);
      }
    });

    conn.on("data", (data) => {
      if (data.type === "file") {
        setMessages((prevMessages) => [
          ...prevMessages,
          { type: "file", content: data.content, fileName: data.fileName },
        ]);
      } else if (data.type === "text") {
        setMessages((prevMessages) => [...prevMessages, data.content]);
      }
    });

    conn.on("close", () => {
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
        <h2>Connected Users ({connectedPeers.length})</h2>
        <ul>
          {connectedPeers.map((id, index) => (
            <li key={index}>
              <span
                style={{
                  display: "inline-block",
                  width: "10px",
                  height: "10px",
                  backgroundColor: "green",
                  borderRadius: "50%",
                  marginRight: "10px",
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
            msg.type === "file" ? (
              <li key={index}>
                {msg.fileName.endsWith(".mp4") ? (
                  <video controls width="300" src={msg.content}></video>
                ) : (
                  <img src={msg.content} alt="Received" width="200" />
                )}
                <a href={msg.content} download={msg.fileName} className="btn">
                  Download {msg.fileName}
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
        onChange={(e) => setFile(e.target.files[0])}
      />
      <button onClick={connectToPeer}>Send</button>
    </div>
  );
}

export default Chat;
