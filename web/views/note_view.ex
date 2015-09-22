defmodule WebappExternalProcess.NoteView do
  use WebappExternalProcess.Web, :view

  alias Porcelain.Process, as: Proc
  alias Porcelain.Result

  def render_assciidoc(source) do
    {:ok, server} = RubyServer.start_link

    RubyServer.call(server, ~s"""
    require 'asciidoctor'
    Asciidoctor.convert "#{source}", header_footer: false, safe: 'safe'
    """)
  end

  def render_title(source) do
    {:ok, server} = RubyServer.start_link

    RubyServer.call(server, ~s"""
    require 'asciidoctor'
    doc = Asciidoctor.load "#{source}", header_footer: false, safe: 'safe'
    doc.doctitle
    """)
  end
end
