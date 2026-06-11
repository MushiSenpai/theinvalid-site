import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const projects = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/projects' }),
  schema: z.object({
    title: z.string(),
    oneliner: z.string(),
    status: z.enum(['building', 'shipped', 'parked']),
    repo: z.string().url(),
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
