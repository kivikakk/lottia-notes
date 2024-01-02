---
title: Home
---

Experienced systems engineer playing with digital design and Nix.

I'm taking notes here.

Last updated: <%= @items.select { |item| item[:kind] == "article" }.map { |item| item[:created_at] }.max.strftime("%Y-%m-%d") %>.
