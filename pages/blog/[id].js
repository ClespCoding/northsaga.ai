import { getAllPostIds, getPostData } from '../../lib/blog';
import Link from 'next/link';

export default function Post({ postData }) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 to-orange-50 p-8">
      <div className="max-w-4xl mx-auto">
        <Link href="/blog" className="text-amber-700 hover:underline mb-8 inline-block">
          ← Back to Blog
        </Link>
        
        <article className="bg-white rounded-lg p-8 shadow-lg">
          <h1 className="text-4xl font-bold mb-4 text-slate-800">
            {postData.title}
          </h1>
          
          <div className="text-slate-600 mb-6">
            {postData.date} • {postData.readTime} min read
          </div>
          
          <div className="flex gap-2 mb-8">
            {postData.tags?.map((tag) => (
              <span key={tag} className="bg-amber-100 text-amber-800 px-3 py-1 rounded">
                #{tag}
              </span>
            ))}
          </div>
          
          <div 
            className="prose max-w-none"
            dangerouslySetInnerHTML={{ __html: postData.contentHtml }} 
          />
        </article>
      </div>
    </div>
  );
}

export async function getStaticPaths() {
  const paths = getAllPostIds();
  return {
    paths,
    fallback: false,
  };
}

export async function getStaticProps({ params }) {
  const postData = await getPostData(params.id);
  return {
    props: {
      postData,
    },
  };
}
