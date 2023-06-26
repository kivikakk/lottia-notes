---
title: Home
---

I'm taking notes here.

Last updated: <%= @items.select { |item| item[:kind] == "article" }.map { |item| item[:created_at] }.max.strftime("%Y-%m-%d") %>.
