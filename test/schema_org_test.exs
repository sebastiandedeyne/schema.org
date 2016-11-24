defmodule SchemaOrgTest do
  use ExUnit.Case
  doctest SchemaOrg

  import SchemaOrg

  test "it can create a new schema" do
    schema = create_schema("MyType")

    assert schema.type == "MyType"
    assert schema.context == "http://schema.org"
  end

  test "it can put a property in a schema" do
    schema = 
      create_schema("MyType")
      |> put_property(:foo, "bar")

    assert schema.properties.foo == "bar"
  end

  test "it can overwrite a property in a schema" do
    schema = 
      create_schema("MyType")
      |> put_property(:foo, "bar")
      |> put_property(:foo, "baz")

    assert schema.properties.foo == "baz"
  end

  test "it can render a schema to json" do
    {:ok, json} = 
      create_schema("MyType")
      |> put_property(:foo, "bar")
      |> to_json
    
    %{"@context" => "http://schema.org",
      "@type" => "MyType",
      "foo" => "bar"} = Poison.decode!(json)
  end

  test "it can render a script" do
    {:ok, script} = 
      create_schema("MyType")
      |> put_property(:foo, "bar")
      |> to_script

    assert String.starts_with?(script, ~s(<script type="application/ld+json">{"))
    assert String.ends_with?(script, ~s("}</script>))
  end
end
