import React from 'react';
import Head from 'next/head';
import Link from 'next/link';

export default function Home() {
  return (
    <>
      <Head>
        <title>North Saga - Where History Meets Technology</title>
        <meta name="description" content="Exploring the maritime merchant networks from Anglo-Saxons to the Hanseatic League through the lens of modern technology" />
      </Head>

      <div className="min-h-screen">
        <span className="folio">Folio I</span>
        
        <header className="max-w-4xl mx-auto px-6 py-8">
          <h1 className="font-display text-5xl text-burgundy text-center mb-2">
            The North Sea Empire
          </h1>
          <p className="text-center text-merchant-gold text-2xl">❦</p>
          <p className="text-center text-ink-brown italic mt-4">
            Where History Meets Technology
          </p>
        </header>

        <div className="flex justify-center my-6">
          <Link href="/blog" className="renaissance-button text-lg px-8 py-3 font-display shadow-lg">
            Read the Chronicles
          </Link>
        </div>

        <nav>
          <ul>
            <li><Link href="/" className="active">Home</Link></li>
            <li><Link href="/blog">Chronicle</Link></li>
            <li><Link href="/tech-codex">Tech Codex</Link></li>
            <li><Link href="/about">About</Link></li>
          </ul>
        </nav>

        <main className="max-w-4xl mx-auto px-6 py-8">
          <article className="space-y-6">
            <p className="drop-cap text-lg text-justify">
              In the annals of maritime history, few entities have captured the imagination quite like 
              the confederation of merchant cities that sprawled across the cold waters of the North Sea. 
              From the bustling ports of Lübeck to the counting houses of London, a network of commerce 
              and culture flourished that would shape the destiny of Northern Europe.
            </p>
            
            <div className="relative">
              <span className="marginalia">Anno Domini 1241</span>
              <p className="text-lg text-justify indent-6">
                The merchants of old dealt in many currencies: 
                <span className="text-merchant-gold font-medium">£</span>12 sterling, 
                <span className="text-merchant-gold font-medium">ƒ</span>45 gulden, and 
                <span className="text-merchant-gold font-medium">₤</span>78 lire. 
                Their ledgers, kept in careful script, recorded transactions that spanned from Bergen to Bruges.
              </p>
            </div>
            
            <div className="section-divider">❦ ❦ ❦</div>
            
            <h2 className="font-display text-3xl text-burgundy mt-9 mb-4 pb-2 border-b border-merchant-gold-light">
              Latest Chronicles
            </h2>
            
            <div className="blog-posts">
              <article className="blog-post">
                <h3><Link href="/blog/technology-behind-history">The Technology Behind History</Link></h3>
                <p className="post-meta">VII July, Anno Domini MMXXV</p>
                <p className="text-base">
                  Discover how we blend ancient narratives with modern web technologies, using artificial intelligence 
                  to illuminate the connections between medieval trade routes and today's digital highways...
                </p>
                <Link href="/blog/technology-behind-history" className="read-more">
                  Continue reading →
                </Link>
              </article>

              <article className="blog-post">
                <h3><Link href="/blog/hanseatic-crypto">From Hanseatic Marks to Cryptocurrency</Link></h3>
                <p className="post-meta">V July, Anno Domini MMXXV</p>
                <p className="text-base">
                  The Hanseatic League pioneered international banking and standardized currency exchange. 
                  Today, we explore how their innovations mirror modern cryptocurrency networks...
                </p>
                <Link href="/blog/hanseatic-crypto" className="read-more">
                  Continue reading →
                </Link>
              </article>
            </div>

            <div className="ornament text-3xl">✦ ✦ ✦</div>

            <div className="renaissance-card mt-12">
              <h3 className="font-display text-2xl text-sea-blue mb-4">Join Our Digital Guild</h3>
              <p className="mb-4">
                Subscribe to receive updates on our latest historical discoveries, technological experiments, 
                and the ongoing chronicle of building this digital manuscript.
              </p>
              <button className="renaissance-button">
                Subscribe to the Chronicle
              </button>
            </div>
          </article>
        </main>

        <footer className="max-w-4xl mx-auto px-6 py-8 mt-16 border-t border-merchant-gold-light">
          <p className="text-center text-ink-brown italic">
            ~ Finis coronat opus ~
          </p>
        </footer>
      </div>
    </>
  );
}