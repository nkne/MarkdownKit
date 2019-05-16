#tag Class
Protected Class Phase1Printer
Implements Global.MarkdownKit.Walker
	#tag Method, Flags = &h21
		Private Function CurrentIndent() As Text
		  // Given the current indentation level (specified by mCurrentIndent), this 
		  // method returns mCurrentIndent * 4 number of spaces as Text.
		  
		  If Not Pretty Then Return ""
		  
		  Dim numSpaces As Integer = mCurrentIndent * kSpacesPerIndent
		  Dim tmp() As Text
		  For i As Integer = 0 To numSpaces
		    tmp.Append(" ")
		  Next i
		  Return Text.Join(tmp, "")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DecreaseIndent()
		  mCurrentIndent = mCurrentIndent - 1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub IncreaseIndent()
		  mCurrentIndent = mCurrentIndent + 1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VisitAtxHeading(atx As MarkdownKit.AtxHeading)
		  // Part of the Global.MarkdownKit.Walker interface.
		  
		  mOutput.Append(CurrentIndent + "<ATXHeading level=" + atx.Level.ToText + ">")
		  mOutput.Append(EOL)
		  
		  For Each b As MarkdownKit.Block In atx.Children
		    IncreaseIndent
		    b.Accept(Self)
		    DecreaseIndent
		  Next b
		  
		  mOutput.Append(CurrentIndent + "</ATXHeading>")
		  mOutput.Append(EOL)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VisitBlock(block As MarkdownKit.Block)
		  // Part of the Global.MarkdownKit.Walker interface.
		  
		  mOutput.Append(CurrentIndent + "<Block>")
		  mOutput.Append(EOL)
		  
		  For Each b As MarkdownKit.Block In block.Children
		    IncreaseIndent
		    b.Accept(Self)
		    DecreaseIndent
		  Next b
		  
		  mOutput.Append(CurrentIndent + "</Block>")
		  mOutput.Append(EOL)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VisitBlockQuote(bq As MarkdownKit.BlockQuote)
		  // Part of the Global.MarkdownKit.Walker interface.
		  
		  mOutput.Append(CurrentIndent + "<BlockQuote>")
		  mOutput.Append(EOL)
		  
		  For Each b As MarkdownKit.Block In bq.Children
		    IncreaseIndent
		    b.Accept(Self)
		    DecreaseIndent
		  Next b
		  
		  mOutput.Append(CurrentIndent + "</BlockQuote>")
		  mOutput.Append(EOL)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VisitDocument(d As MarkdownKit.Document)
		  // Part of the Global.MarkdownKit.Walker interface.
		  
		  mOutput.Append(CurrentIndent + "<Document>")
		  mOutput.Append(EOL)
		  
		  For Each b As MarkdownKit.Block In d.Children
		    IncreaseIndent
		    b.Accept(Self)
		    DecreaseIndent
		  Next b
		  
		  mOutput.Append(CurrentIndent + "</Document>")
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VisitFencedCode(f As MarkdownKit.FencedCode)
		  // Part of the Global.MarkdownKit.Walker interface.
		  
		  Dim info As Text = If(f.InfoString <> "", " info=" + """" + f.InfoString + """", "")
		  
		  mOutput.Append(CurrentIndent + "<FencedCodeBlock" + If(info <> "", info, "") + ">")
		  mOutput.Append(EOL)
		  
		  For Each b As MarkdownKit.Block In f.Children
		    IncreaseIndent
		    b.Accept(Self)
		    DecreaseIndent
		  Next b
		  
		  mOutput.Append(CurrentIndent + "</FencedCodeBlock>")
		  mOutput.Append(EOL)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VisitHardBreak(hb As MarkdownKit.HardBreak)
		  #Pragma Unused hb
		  
		  // Part of the Global.MarkdownKit.Walker interface.
		  
		  mOutput.Append(CurrentIndent + "<HardBreak />")
		  mOutput.Append(EOL)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VisitIndentedCode(i As MarkdownKit.IndentedCode)
		  // Part of the Global.MarkdownKit.Walker interface.
		  
		  mOutput.Append(CurrentIndent + "<IndentedCodeBlock>")
		  mOutput.Append(EOL)
		  
		  For Each b As MarkdownKit.Block In i.Children
		    IncreaseIndent
		    b.Accept(Self)
		    DecreaseIndent
		  Next b
		  
		  mOutput.Append(CurrentIndent + "</IndentedCodeBlock>")
		  mOutput.Append(EOL)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VisitParagraph(p As MarkdownKit.Paragraph)
		  // Part of the Global.MarkdownKit.Walker interface.
		  
		  mOutput.Append(CurrentIndent + "<Paragraph>")
		  mOutput.Append(EOL)
		  
		  For Each b As MarkdownKit.Block In p.Children
		    IncreaseIndent
		    b.Accept(Self)
		    DecreaseIndent
		  Next b
		  
		  mOutput.Append(CurrentIndent + "</Paragraph>")
		  mOutput.Append(EOL)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VisitRawText(rt As MarkdownKit.RawText)
		  // Part of the Global.MarkdownKit.Walker interface.
		  
		  mOutput.Append(CurrentIndent + "<RawText>")
		  
		  // For readability, we will replace spaces with a bullet (•), tabs with an arrow (→) 
		  // and blank lines with the return arrow (⮐).
		  Dim tmp() As Text
		  Dim i As Integer
		  Dim charsUbound As Integer = rt.Chars.Ubound
		  For i = 0 To charsUbound
		    If rt.Chars(i) = " " Then
		      tmp.Append("•")
		    ElseIf rt.Chars(i) = &u0009 Then
		      tmp.Append("→")
		    Else
		      tmp.Append(rt.Chars(i))
		    End If
		  Next i
		  If tmp.Ubound = -1 Then tmp.Append("⮐") // Blank line.
		  
		  mOutput.Append(Text.Join(tmp, ""))
		  mOutput.Append("</RawText>")
		  mOutput.Append(EOL)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VisitSoftBreak(sb As MarkdownKit.SoftBreak)
		  #Pragma Unused sb
		  
		  // Part of the Global.MarkdownKit.Walker interface.
		  
		  mOutput.Append(CurrentIndent + "<SoftBreak />")
		  mOutput.Append(EOL)
		  
		End Sub
	#tag EndMethod


	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  Return &u000A
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // Read only.
			End Set
		#tag EndSetter
		Private EOL As Text
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mCurrentIndent As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOutput() As Text
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Text.Join(mOutput, "")
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // Read only.
			  
			End Set
		#tag EndSetter
		Output As Text
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		Pretty As Boolean = True
	#tag EndProperty


	#tag Constant, Name = kSpacesPerIndent, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Output"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Pretty"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass