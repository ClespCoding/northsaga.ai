import { getSortedPostsData } from '../../lib/blog';
import Link from 'next/link';

export default function Blog({ allPostsData }) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 to-orange-50 p-8">
      <div className="max-w-4xl mx-auto">
        <Link href="/" className="text-amber-700 hover:underline mb-8 inline-block">
          ← Back to Home
        </Link>
        
        <h1 className="text-4xl font-bold mb-8 text-slate-800">
          The North Saga Chronicles
        </h1>
        
        <div className="space-y-8">
          {allPostsData.map(({ id, title, excerpt, date, tags }) => (
            <article key={id} className="bg-white rounded-lg p-6 shadow-lg">
              <h2 className="text-2xl font-bold mb-3">
                <Link href={`/blog/${id}`} className="text-slate-800 hover:text-amber-700">
                  {title}
                </Link>
              </h2>
              <p className="text-slate-600 mb-4">{excerpt}</p>
              <div className="flex gap-2 mb-4">
                {tags?.map((tag) => (
                  <span key={tag} className="bg-amber-100 text-amber-800 px-2 py-1 rounded text-sm">
                    #{tag}
                  </span>
                ))}
              </div>
              <Link href={`/blog/${id}`} className="text-amber-700 hover:underline">
                Read more →
              </Link>
            </article>
          ))}
        </div>
      </div>
    </div>
  );
}

export async function getStaticProps() {
  const allPostsData = getSortedPostsData();
  return {
    props: {
      allPostsData,
    },
  };
}
