import React, { useState } from 'react';
import { Ship, Compass, BookOpen, Code, Youtube, Share2, Clock, Globe } from 'lucide-react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';

export default function NorthSagaHome() {
  const [activeSection, setActiveSection] = useState('saga');

  const sections = {
    saga: { icon: Ship, title: 'The Saga' },
    tech: { icon: Code, title: 'Tech Journey' },
    content: { icon: BookOpen, title: 'Content Hub' },
    connect: { icon: Share2, title: 'Connect' }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Navigation */}
      <nav className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="container flex h-14 items-center justify-between">
          <div className="flex items-center space-x-2">
            <Ship className="h-6 w-6 text-primary" />
            <span className="text-xl font-bold">NorthSaga.ai</span>
          </div>
          <div className="flex space-x-1">
            {Object.entries(sections).map(([key, section]) => (
              <Button
                key={key}
                variant={activeSection === key ? "default" : "ghost"}
                size="sm"
                onClick={() => setActiveSection(key)}
                className="flex items-center space-x-1"
              >
                <section.icon className="h-4 w-4" />
                <span className="hidden sm:inline">{section.title}</span>
              </Button>
            ))}
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="container space-y-6 py-8 md:py-12 lg:py-20">
        <div className="mx-auto flex max-w-4xl flex-col items-center space-y-4 text-center">
          <h1 className="text-3xl font-bold leading-tight tracking-tighter md:text-5xl lg:text-6xl lg:leading-[1.1]">
            Where History Meets
            <span className="text-primary"> Technology</span>
          </h1>
          <p className="max-w-2xl text-lg text-muted-foreground sm:text-xl">
            Exploring the North Sea Empire, Hanseatic League, and the digital threads that connect 
            ancient trade routes to modern innovation. Built with AI, deployed with passion.
          </p>
          
          {/* QR Code Card */}
          <Card className="w-40 h-40 flex items-center justify-center">
            <CardContent className="flex flex-col items-center space-y-2 pt-6">
              <Share2 className="h-8 w-8 text-muted-foreground" />
              <p className="text-sm text-muted-foreground">QR Code</p>
              <Badge variant="outline">Mar-Soc-QR-main</Badge>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* Main Content */}
      <section className="container py-8">
        <Tabs value={activeSection} onValueChange={setActiveSection} className="w-full">
          <TabsList className="grid w-full grid-cols-4">
            {Object.entries(sections).map(([key, section]) => (
              <TabsTrigger key={key} value={key} className="flex items-center space-x-1">
                <section.icon className="h-4 w-4" />
                <span className="hidden sm:inline">{section.title}</span>
              </TabsTrigger>
            ))}
          </TabsList>

          <TabsContent value="saga" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center text-2xl">
                  <Ship className="mr-3 h-6 w-6" />
                  The North Sea Saga
                </CardTitle>
                <CardDescription className="text-base">
                  From Viking longships to Hanseatic cogs, explore how maritime networks shaped 
                  European civilization. We trace the digital DNA of ancient trade routes.
                </CardDescription>
              </CardHeader>
              <CardContent className="grid gap-6 md:grid-cols-2">
                <div className="space-y-4">
                  <div className="flex items-center space-x-3">
                    <Clock className="h-5 w-5 text-muted-foreground" />
                    <span>793 AD - Viking Age Begins</span>
                  </div>
                  <div className="flex items-center space-x-3">
                    <Globe className="h-5 w-5 text-muted-foreground" />
                    <span>1200s - Hanseatic League Forms</span>
                  </div>
                  <div className="flex items-center space-x-3">
                    <Code className="h-5 w-5 text-muted-foreground" />
                    <span>2024 - Digital Reconstruction</span>
                  </div>
                </div>
                <Card>
                  <CardHeader>
                    <CardTitle>Timeline Hub</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <Badge variant="secondary">dev-data-timeline-core</Badge>
                    <Badge variant="secondary">dev-data-blog-chart</Badge>
                    <Badge variant="secondary">mar-content-timeline</Badge>
                  </CardContent>
                </Card>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="tech" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center text-2xl">
                  <Code className="mr-3 h-6 w-6" />
                  Our Tech Journey
                </CardTitle>
              </CardHeader>
              <CardContent className="grid gap-6 md:grid-cols-3">
                <Card>
                  <CardHeader>
                    <CardTitle>Development Stack</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <p className="text-sm">• Next.js + React</p>
                    <p className="text-sm">• Shadcn/ui Components</p>
                    <p className="text-sm">• Vercel Deployment</p>
                    <p className="text-sm">• AI-Assisted Development</p>
                    <p className="text-sm">• GitHub Integration</p>
                    <Badge variant="outline" className="mt-2">NS-dev-core-stack</Badge>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader>
                    <CardTitle>Content Pipeline</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <p className="text-sm">• AI Research Assistant</p>
                    <p className="text-sm">• Automated Blog Generation</p>
                    <p className="text-sm">• YouTube Shorts</p>
                    <p className="text-sm">• Social Media QR Codes</p>
                    <Badge variant="outline" className="mt-2">NS-content-pipeline</Badge>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader>
                    <CardTitle>Monetization</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <p className="text-sm">• Affiliate Marketing</p>
                    <p className="text-sm">• Crypto Integration</p>
                    <p className="text-sm">• Digital Products</p>
                    <p className="text-sm">• Consulting Services</p>
                    <Badge variant="outline" className="mt-2">NS-commerce-hub</Badge>
                  </CardContent>
                </Card>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="content" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center text-2xl">
                  <BookOpen className="mr-3 h-6 w-6" />
                  Content Ecosystem
                </CardTitle>
              </CardHeader>
              <CardContent className="grid gap-6 md:grid-cols-2">
                <div className="space-y-4">
                  <Card>
                    <CardHeader>
                      <CardTitle>Blog Series</CardTitle>
                      <CardDescription>
                        Deep dives into historical connections and tech implementation
                      </CardDescription>
                    </CardHeader>
                    <CardContent>
                      <Badge variant="outline">content-blog-series</Badge>
                    </CardContent>
                  </Card>
                  <Card>
                    <CardHeader>
                      <CardTitle>YouTube Shorts</CardTitle>
                      <CardDescription>
                        Bite-sized historical insights with QR code CTAs
                      </CardDescription>
                    </CardHeader>
                    <CardContent>
                      <Badge variant="outline">mar-soc-yt-shorts</Badge>
                    </CardContent>
                  </Card>
                </div>
                <div className="space-y-4">
                  <Card>
                    <CardHeader>
                      <CardTitle>Affiliate Hub</CardTitle>
                      <CardDescription>
                        Curated historical books and educational resources
                      </CardDescription>
                    </CardHeader>
                    <CardContent>
                      <Badge variant="outline">mar-aff-book-hub</Badge>
                    </CardContent>
                  </Card>
                  <Card>
                    <CardHeader>
                      <CardTitle>Interactive Maps</CardTitle>
                      <CardDescription>
                        Digital recreation of historical trade routes
                      </CardDescription>
                    </CardHeader>
                    <CardContent>
                      <Badge variant="outline">dev-data-maps-interactive</Badge>
                    </CardContent>
                  </Card>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="connect" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center justify-center text-2xl">
                  <Share2 className="mr-3 h-6 w-6" />
                  Connect & Collaborate
                </CardTitle>
              </CardHeader>
              <CardContent className="grid gap-6 md:grid-cols-3">
                <Card className="text-center">
                  <CardContent className="pt-6">
                    <Youtube className="mx-auto mb-4 h-12 w-12" />
                    <CardTitle className="mb-2">YouTube</CardTitle>
                    <CardDescription>
                      Historical insights meet modern tech
                    </CardDescription>
                  </CardContent>
                </Card>
                <Card className="text-center">
                  <CardContent className="pt-6">
                    <Share2 className="mx-auto mb-4 h-12 w-12" />
                    <CardTitle className="mb-2">Social Links</CardTitle>
                    <CardDescription>
                      QR codes bridge digital and physical
                    </CardDescription>
                  </CardContent>
                </Card>
                <Card className="text-center">
                  <CardContent className="pt-6">
                    <Compass className="mx-auto mb-4 h-12 w-12" />
                    <CardTitle className="mb-2">Partnerships</CardTitle>
                    <CardDescription>
                      Collaborate with historians and educators
                    </CardDescription>
                  </CardContent>
                </Card>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </section>

      <Separator />

      {/* Footer */}
      <footer className="py-6 md:py-0">
        <div className="container flex flex-col items-center justify-center gap-4 md:h-24 md:flex-row">
          <p className="text-center text-sm leading-loose text-muted-foreground md:text-left">
            Built with AI assistance • Deployed on Vercel • Open Source Philosophy
          </p>
        </div>
      </footer>
    </div>
  );
}