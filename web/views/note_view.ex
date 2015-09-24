defmodule WebappExternalProcess.NoteView do
  use WebappExternalProcess.Web, :view

  alias Porcelain.Process, as: Proc
  alias Porcelain.Result

  def render_assciidoc(source) do
    {:ok, server} = RubyServer.start_link

    escaped_source = escape_ruby_string source
    RubyServer.call(server, ~s"""
    require 'asciidoctor'
    html = Asciidoctor.convert '#{escaped_source}', header_footer: false, safe: 'safe'
    html || ""
    """)
  end

  def render_title(source) do
    {:ok, server} = RubyServer.start_link

    escaped_source = escape_ruby_string source
    RubyServer.call(server, ~s"""
    require 'asciidoctor'
    doc = Asciidoctor.load '#{escaped_source}', header_footer: false, safe: 'safe'
    doc.doctitle || ""
    """)
  end

  defp escape_ruby_string(str) do
    String.replace(str, "\'", "\\'")
  end
end
