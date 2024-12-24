local function generate_big_file(filename, num_paragraphs)
  -- Open file for writing
  local file = io.open(filename, "w")
  if not file then
    error("Could not open file: " .. filename)
  end

  -- Some sample words to generate semi-meaningful content
  local subjects =
    { "The system", "The user", "The process", "The application", "The data" }
  local verbs = { "processes", "handles", "manages", "analyzes", "transforms" }
  local objects =
    { "information", "requests", "data", "inputs", "configurations" }

  -- Generate content
  for i = 1, num_paragraphs do
    -- Generate a paragraph with 5-10 sentences
    local sentences = math.random(5, 10)
    for j = 1, sentences do
      local subject = subjects[math.random(#subjects)]
      local verb = verbs[math.random(#verbs)]
      local object = objects[math.random(#objects)]

      -- Create a sentence and add some random additional clauses
      local sentence = string.format("%s %s %s", subject, verb, object)
      if math.random() > 0.5 then
        sentence = sentence .. " while maintaining optimal performance"
      end
      if math.random() > 0.7 then
        sentence = sentence .. " in a distributed environment"
      end

      file:write(sentence .. ". ")
    end
    file:write("\n\n") -- Add paragraph break
  end

  file:close()
end

local function generate_large_json_file(filename, num_records)
  local file = io.open(filename, "w")
  if not file then
    error("Could not open file: " .. filename)
  end

  -- Sample data arrays for variety
  local names =
    { "John", "Alice", "Bob", "Emma", "David", "Sarah", "Michael", "Lisa" }
  local cities =
    { "New York", "London", "Tokyo", "Paris", "Berlin", "Sydney", "Toronto" }
  local statuses = { "active", "pending", "completed", "archived", "deleted" }
  local types = { "user", "admin", "guest", "moderator" }

  -- Write JSON opening bracket
  file:write('{\n  "records": [\n')

  -- Generate records
  for i = 1, num_records do
    local record = string.format(
      [[    {
      "id": %d,
      "uuid": "%s-%d",
      "name": "%s",
      "age": %d,
      "city": "%s",
      "email": "%s@example.com",
      "status": "%s",
      "type": "%s",
      "created_at": "%d-%02d-%02dT%02d:%02d:%02dZ",
      "score": %.2f,
      "is_active": %s
    }]],
      i,
      string.char(math.random(65, 90)) .. string.char(math.random(65, 90)),
      i,
      names[math.random(#names)],
      math.random(18, 80),
      cities[math.random(#cities)],
      string.lower(names[math.random(#names)]),
      statuses[math.random(#statuses)],
      types[math.random(#types)],
      math.random(2020, 2023),
      math.random(1, 12),
      math.random(1, 28),
      math.random(0, 23),
      math.random(0, 59),
      math.random(0, 59),
      math.random() * 100,
      tostring(math.random() > 0.5)
    )

    file:write(record)
    if i < num_records then
      file:write(",\n")
    else
      file:write("\n")
    end
  end

  -- Write JSON closing brackets
  file:write("  ]\n}")
  file:close()
end

-- Usage example:
generate_large_json_file("large_data1.json", 100000) -- Will generate ~10000 records
-- generate_big_file("large_text1.txt", 10000) -- Will generate ~1000 paragraphs
