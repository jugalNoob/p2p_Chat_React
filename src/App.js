import React from 'react';
import { Route, Routes } from 'react-router-dom';
import Chat from './page/Chat';
import Home from './page/Home.jsx';
import Video from './page/Video.jsx';




function App() {
  return (
    <div>

          <Routes>

  <Route path="/" element={<Home />} />
  <Route path="/chat" element={<Chat />} />
  <Route path="/video" element={<Video />} />


  </Routes>
    </div>
  )
}

export default App