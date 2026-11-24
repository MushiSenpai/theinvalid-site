import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const projects = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/projects' }),
  schema: z.object({
    title: z.string(),
    oneliner: z.string(),
    // planned = designed and decided, nothing built yet. Said plainly.
    status: z.enum(['building', 'shipped', 'parked', 'planned']),
    // Optional: a project can exist before its repo is public (e.g. QLAB).
    repo: z.string().url().optional(),
    // Optional: site-relative path to the project's flagship case study.
    caseStudy: z.string().optional(),
    // Optional: site-relative path to the public write-up (a blog post). Used by
    // private builds, whose only public surface is what was written about them.
    writeup: z.string().optional(),
    // true = the repo stays private (commercial, security, or personal data).
    // The page says so plainly instead of showing a dead repo link.
    private: z.boolean().default(false),
    stack: z.array(z.string()),
    started: z.coerce.date(),
    order: z.number().default(99),
  }),
});

const blog = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/blog' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    date: z.coerce.date(),
    project: z.string().optional(),
    tags: z.array(z.string()).default([]),
  }),
});

export const collections = { projects, blog };
