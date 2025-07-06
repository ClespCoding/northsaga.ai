import React, { useState } from 'react';
import { Ship, Compass, BookOpen, Code, Youtube, Share2, Clock, Globe } from 'lucide-react';

export default function NorthSagaHome() {
  const [activeSection, setActiveSection] = useState('saga');

  const sections = {
    saga: { icon: Ship, title: 'The Saga', color: 'from-blue-600 to-cyan-500' },
    tech: { icon: Code, title: 'Tech Journey', color: 'from-purple-600 to-pink-500' },
    content: { icon: BookOpen, title: 'Content Hub', color: 'from-green-600 to-emerald-500' },
    connect: { icon: Share2, title: 'Connect', color: 'from-orange-600 to-red-500' }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-800 text-white">
      {/* Navigation */}
      <nav className="fixed top-0 w-full bg-black/20 backdrop-blur-md z-50 border-b border-white/10">
        <div className="max-w-6xl mx-auto px-4 py-4 flex justify-between items-center">
          <div className="flex items-center space-x-2">
            <Ship className="w-8 h-8 text-cyan-400" />
            <span className="text-2xl font-bold bg-gradient-to-r from-cyan-400 to-blue-400 bg-clip-text text-transparent">
              NorthSaga.ai
            </span>
          </div>
          <div className="flex space-x-6">
            {Object.entries(sections).map(([key, section]) => (
              <button
                key={key}
                onClick={() => setActiveSection(key)}
                className={`flex items-center space-x-2 px-4 py-2 rounded-lg transition-all duration-300 ${
                  activeSection === key 
                    ? 'bg-white/20 text-white' 
                    : 'text-gray-300 hover:text-white hover:bg-white/10'
                }`}
              >
                <section.icon className="w-4 h-4" />
                <span>{section.title}</span>
              </button>
            ))}
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <div className="pt-24 pb-16 px-4">
        <div className="max-w-6xl mx-auto text-center">
          <h1 className="text-6xl font-bold mb-6 bg-gradient-to-r from-cyan-400 via-blue-400 to-purple-400 bg-clip-text text-transparent">
            Where History Meets Technology
          </h1>
          <p className="text-xl text-gray-300 mb-8 max-w-3xl mx-auto">
            Exploring the North Sea Empire, Hanseatic League, and the digital threads that connect 
            ancient trade routes to modern innovation. Built with AI, deployed with passion.
          </p>
          
          {/* QR Code Placeholder */}
          <div className="inline-flex items-center justify-center w-32 h-32 bg-white/10 rounded-xl border-2 border-dashed border-white/30 mb-8">
            <div className="text-center">
              <Share2 className="w-8 h-8 mx-auto mb-2 text-gray-400" />
              <span className="text-sm text-gray-400">QR Code</span>
              <div className="text-xs text-gray-500 mt-1">Mar-Soc-QR-main</div>
            </div>
          </div>
        </div>
      </div>

      {/* Dynamic Content Section */}
      <div className="max-w-6xl mx-auto px-4 pb-16">
        <div className={`bg-gradient-to-r ${sections[activeSection].color} p-8 rounded-2xl shadow-2xl`}>
          {activeSection === 'saga' && (
            <div className="grid md:grid-cols-2 gap-8">
              <div>
                <h2 className="text-3xl font-bold mb-4 flex items-center">
                  <Ship className="w-8 h-8 mr-3" />
                  The North Sea Saga
                </h2>
                <p className="text-lg mb-6 text-white/90">
                  From Viking longships to Hanseatic cogs, explore how maritime networks shaped 
                  European civilization. We trace the digital DNA of ancient trade routes.
                </p>
                <div className="space-y-3">
                  <div className="flex items-center space-x-3">
                    <Clock className="w-5 h-5" />
                    <span>793 AD - Viking Age Begins</span>
                  </div>
                  <div className="flex items-center space-x-3">
                    <Globe className="w-5 h-5" />
                    <span>1200s - Hanseatic League Forms</span>
                  </div>
                  <div className="flex items-center space-x-3">
                    <Code className="w-5 h-5" />
                    <span>2024 - Digital Reconstruction</span>
                  </div>
                </div>
              </div>
              <div className="bg-white/10 rounded-xl p-6 backdrop-blur-sm">
                <h3 className="text-xl font-semibold mb-4">Timeline Hub</h3>
                <div className="space-y-2 text-sm">
                  <div className="p-2 bg-white/10 rounded">dev-data-timeline-core</div>
                  <div className="p-2 bg-white/10 rounded">dev-data-blog-chart</div>
                  <div className="p-2 bg-white/10 rounded">mar-content-timeline</div>
                </div>
              </div>
            </div>
          )}

          {activeSection === 'tech' && (
            <div>
              <h2 className="text-3xl font-bold mb-4 flex items-center">
                <Code className="w-8 h-8 mr-3" />
                Our Tech Journey
              </h2>
              <div className="grid md:grid-cols-3 gap-6">
                <div className="bg-white/10 rounded-xl p-6 backdrop-blur-sm">
                  <h3 className="text-xl font-semibold mb-3">Development Stack</h3>
                  <ul className="space-y-2 text-sm">
                    <li>• Next.js + React</li>
                    <li>• Vercel Deployment</li>
                    <li>• AI-Assisted Development</li>
                    <li>• GitHub Integration</li>
                  </ul>
                  <div className="mt-4 text-xs text-white/70">NS-dev-core-stack</div>
                </div>
                <div className="bg-white/10 rounded-xl p-6 backdrop-blur-sm">
                  <h3 className="text-xl font-semibold mb-3">Content Pipeline</h3>
                  <ul className="space-y-2 text-sm">
                    <li>• AI Research Assistant</li>
                    <li>• Automated Blog Generation</li>
                    <li>• YouTube Shorts</li>
                    <li>• Social Media QR Codes</li>
                  </ul>
                  <div className="mt-4 text-xs text-white/70">NS-content-pipeline</div>
                </div>
                <div className="bg-white/10 rounded-xl p-6 backdrop-blur-sm">
                  <h3 className="text-xl font-semibold mb-3">Monetization</h3>
                  <ul className="space-y-2 text-sm">
                    <li>• Affiliate Marketing</li>
                    <li>• Crypto Integration</li>
                    <li>• Digital Products</li>
                    <li>• Consulting Services</li>
                  </ul>
                  <div className="mt-4 text-xs text-white/70">NS-commerce-hub</div>
                </div>
              </div>
            </div>
          )}

          {activeSection === 'content' && (
            <div>
              <h2 className="text-3xl font-bold mb-4 flex items-center">
                <BookOpen className="w-8 h-8 mr-3" />
                Content Ecosystem
              </h2>
              <div className="grid md:grid-cols-2 gap-8">
                <div className="space-y-4">
                  <div className="bg-white/10 rounded-xl p-4 backdrop-blur-sm">
                    <h3 className="font-semibold mb-2">Blog Series</h3>
                    <p className="text-sm text-white/90">Deep dives into historical connections and tech implementation</p>
                    <div className="text-xs text-white/70 mt-2">content-blog-series</div>
                  </div>
                  <div className="bg-white/10 rounded-xl p-4 backdrop-blur-sm">
                    <h3 className="font-semibold mb-2">YouTube Shorts</h3>
                    <p className="text-sm text-white/90">Bite-sized historical insights with QR code CTAs</p>
                    <div className="text-xs text-white/70 mt-2">mar-soc-yt-shorts</div>
                  </div>
                </div>
                <div className="space-y-4">
                  <div className="bg-white/10 rounded-xl p-4 backdrop-blur-sm">
                    <h3 className="font-semibold mb-2">Affiliate Hub</h3>
                    <p className="text-sm text-white/90">Curated historical books and educational resources</p>
                    <div className="text-xs text-white/70 mt-2">mar-aff-book-hub</div>
                  </div>
                  <div className="bg-white/10 rounded-xl p-4 backdrop-blur-sm">
                    <h3 className="font-semibold mb-2">Interactive Maps</h3>
                    <p className="text-sm text-white/90">Digital recreation of historical trade routes</p>
                    <div className="text-xs text-white/70 mt-2">dev-data-maps-interactive</div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeSection === 'connect' && (
            <div className="text-center">
              <h2 className="text-3xl font-bold mb-6 flex items-center justify-center">
                <Share2 className="w-8 h-8 mr-3" />
                Connect & Collaborate
              </h2>
              <div className="grid md:grid-cols-3 gap-6">
                <div className="bg-white/10 rounded-xl p-6 backdrop-blur-sm">
                  <Youtube className="w-12 h-12 mx-auto mb-4" />
                  <h3 className="text-xl font-semibold mb-2">YouTube</h3>
                  <p className="text-sm text-white/90">Historical insights meet modern tech</p>
                </div>
                <div className="bg-white/10 rounded-xl p-6 backdrop-blur-sm">
                  <Share2 className="w-12 h-12 mx-auto mb-4" />
                  <h3 className="text-xl font-semibold mb-2">Social Links</h3>
                  <p className="text-sm text-white/90">QR codes bridge digital and physical</p>
                </div>
                <div className="bg-white/10 rounded-xl p-6 backdrop-blur-sm">
                  <Compass className="w-12 h-12 mx-auto mb-4" />
                  <h3 className="text-xl font-semibold mb-2">Partnerships</h3>
                  <p className="text-sm text-white/90">Collaborate with historians and educators</p>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Footer */}
      <footer className="border-t border-white/10 mt-16 py-8">
        <div className="max-w-6xl mx-auto px-4 text-center text-gray-400">
          <p>Built with AI assistance • Deployed on Vercel • Open Source Philosophy</p>
          <p className="text-sm mt-2">Where ancient wisdom meets cutting-edge technology</p>
        </div>
      </footer>
    </div>
  );
}
