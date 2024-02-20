%{
  title: "Deep Dive into Upserts using Ecto",
  tags: ["ecto", "elixir"],
  published: false,
  discussion_url: "",
  description: """
  How to do upserts in ecto?
  """
}
---


## What is an upsert?


## What is requirement for an upsert?
* unique_index 
* id passing


## Ways to upsert 
* get the record and then update it
* Use `on_conflict` with `insert` and `update` in a single query

## UPSERT SQL query and options 
upsert_query = """
  INSERT INTO table_name (id, column1, column2)
  VALUES (1, 'value1', 'value2')
  ON CONFLICT (id) DO UPDATE
  SET column1 = excluded.column1,
      column2 = excluded.column2;
"""

IO.puts(upsert_query)


## Upsert on associations
belongs_to , has_many 



## Upsert on nested associations 

Artist has_many Albums
Album has_many Song
Song belongs_to Album

upsert song => update album and update artist

- [ ] also show SQL query for this
