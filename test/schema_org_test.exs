defmodule SchemaOrgTest do
  use ExUnit.Case
  doctest SchemaOrg

  import SchemaOrg

  test "it can create a new schema" do
    schema = create_schema("MyType")

    assert schema.type == "MyType"
    assert schema.context == "http://schema.org"
  end

  test "it can create a new schema with properties" do
    schema = create_schema("MyType", %{:foo => "bar"})

    assert schema.type == "MyType"
    assert schema.context == "http://schema.org"
    assert schema.properties.foo == "bar"
  end

  test "it can put a property in a schema" do
    schema = 
      create_schema("MyType")
      |> set_property(:foo, "bar")

    assert schema.properties.foo == "bar"
  end

  test "it can overwrite a property in a schema" do
    schema = 
      create_schema("MyType")
      |> set_property(:foo, "bar")
      |> set_property(:foo, "baz")

    assert schema.properties.foo == "baz"
  end

  test "it can convert a schema to a map" do
    {:ok, map} = 
      create_schema("MyType")
      |> set_property(:foo, "bar")
      |> set_property(:child, create_schema("MyChildType"))
      |> to_map
  
    %{"@context" => "http://schema.org",
      "@type" => "MyType",
      :foo => "bar",
      :child => %{"@type" => "MyChildType"}} = map
  end

  test "it removed unnecessary context properties in nested types" do
    {:ok, map} = 
      create_schema("MyType")
      |> set_property(:foo, "bar")
      |> set_property(:child, create_schema("MyChildType"))
      |> to_map

    assert ! Map.has_key?(map.child, "@context")
  end

  test "it can convert a schema to json" do
    {:ok, json} = 
      create_schema("MyType")
      |> set_property(:foo, "bar")
      |> to_json
    
    %{"@context" => "http://schema.org",
      "@type" => "MyType",
      "foo" => "bar"} = Poison.decode!(json)
  end

  test "it can convert a schema to a script" do
    {:ok, script} = 
      create_schema("MyType")
      |> set_property(:foo, "bar")
      |> to_script

    assert String.starts_with?(script, ~s(<script type="application/ld+json">{"))
    assert String.ends_with?(script, ~s("}</script>))
  end
end
