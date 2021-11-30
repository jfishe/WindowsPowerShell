# This script enables bash autocompletion for pandoc.  To enable
# bash completion, add this to your .bashrc:
# eval "$(pandoc --bash-completion)"

_pandoc()
{
    local cur prev opts lastc informats outformats highlight_styles datafiles
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # These should be filled in by pandoc:
    opts="-f -r --from --read -t -w --to --write -o --output --data-dir -M --metadata --metadata-file -d --defaults --file-scope --sandbox -s --standalone --template -V --variable --wrap --ascii --toc --table-of-contents --toc-depth -N --number-sections --number-offset --top-level-division --extract-media --resource-path -H --include-in-header -B --include-before-body -A --include-after-body --no-highlight --highlight-style --syntax-definition --dpi --eol --columns -p --preserve-tabs --tab-stop --pdf-engine --pdf-engine-opt --reference-doc --self-contained --request-header --no-check-certificate --abbreviations --indented-code-classes --default-image-extension -F --filter -L --lua-filter --shift-heading-level-by --base-header-level --strip-empty-paragraphs --track-changes --strip-comments --reference-links --reference-location --atx-headers --markdown-headings --listings -i --incremental --slide-level --section-divs --html-q-tags --email-obfuscation --id-prefix -T --title-prefix -c --css --epub-subdirectory --epub-cover-image --epub-metadata --epub-embed-font --epub-chapter-level --ipynb-output -C --citeproc --bibliography --csl --citation-abbreviations --natbib --biblatex --mathml --webtex --mathjax --katex --gladtex --trace --dump-args --ignore-args --verbose --quiet --fail-if-warnings --log --bash-completion --list-input-formats --list-output-formats --list-extensions --list-highlight-languages --list-highlight-styles -D --print-default-template --print-default-data-file --print-highlight-style -v --version -h --help"
    informats="biblatex bibtex commonmark commonmark_x creole csljson csv docbook docx dokuwiki epub fb2 gfm haddock html ipynb jats jira json latex man markdown markdown_github markdown_mmd markdown_phpextra markdown_strict mediawiki muse native odt opml org rst rtf t2t textile tikiwiki twiki vimwiki"
    outformats="asciidoc asciidoctor beamer biblatex bibtex commonmark commonmark_x context csljson docbook docbook4 docbook5 docx dokuwiki dzslides epub epub2 epub3 fb2 gfm haddock html html4 html5 icml ipynb jats jats_archiving jats_articleauthoring jats_publishing jira json latex man markdown markdown_github markdown_mmd markdown_phpextra markdown_strict mediawiki ms muse native odt opendocument opml org pdf plain pptx revealjs rst rtf s5 slideous slidy tei texinfo textile xwiki zimwiki"
    highlight_styles="pygments tango espresso zenburn kate monochrome breezedark haddock"
    datafiles="reference.docx reference.odt reference.pptx MANUAL.txt docx/_rels/.rels pptx/_rels/.rels abbreviations bash_completion.tpl creole.lua default.csl docx/[Content_Types].xml docx/docProps/app.xml docx/docProps/core.xml docx/docProps/custom.xml docx/word/_rels/document.xml.rels docx/word/_rels/footnotes.xml.rels docx/word/comments.xml docx/word/document.xml docx/word/fontTable.xml docx/word/footnotes.xml docx/word/numbering.xml docx/word/settings.xml docx/word/styles.xml docx/word/theme/theme1.xml docx/word/webSettings.xml dzslides/template.html epub.css init.lua odt/Configurations2/accelerator/current.xml odt/META-INF/manifest.xml odt/Thumbnails/thumbnail.png odt/content.xml odt/manifest.rdf odt/meta.xml odt/mimetype odt/settings.xml odt/styles.xml pandoc.List.lua pandoc.lua pptx/[Content_Types].xml pptx/docProps/app.xml pptx/docProps/core.xml pptx/ppt/_rels/presentation.xml.rels pptx/ppt/notesMasters/_rels/notesMaster1.xml.rels pptx/ppt/notesMasters/notesMaster1.xml pptx/ppt/notesSlides/_rels/notesSlide1.xml.rels pptx/ppt/notesSlides/_rels/notesSlide2.xml.rels pptx/ppt/notesSlides/notesSlide1.xml pptx/ppt/notesSlides/notesSlide2.xml pptx/ppt/presProps.xml pptx/ppt/presentation.xml pptx/ppt/slideLayouts/_rels/slideLayout1.xml.rels pptx/ppt/slideLayouts/_rels/slideLayout10.xml.rels pptx/ppt/slideLayouts/_rels/slideLayout11.xml.rels pptx/ppt/slideLayouts/_rels/slideLayout2.xml.rels pptx/ppt/slideLayouts/_rels/slideLayout3.xml.rels pptx/ppt/slideLayouts/_rels/slideLayout4.xml.rels pptx/ppt/slideLayouts/_rels/slideLayout5.xml.rels pptx/ppt/slideLayouts/_rels/slideLayout6.xml.rels pptx/ppt/slideLayouts/_rels/slideLayout7.xml.rels pptx/ppt/slideLayouts/_rels/slideLayout8.xml.rels pptx/ppt/slideLayouts/_rels/slideLayout9.xml.rels pptx/ppt/slideLayouts/slideLayout1.xml pptx/ppt/slideLayouts/slideLayout10.xml pptx/ppt/slideLayouts/slideLayout11.xml pptx/ppt/slideLayouts/slideLayout2.xml pptx/ppt/slideLayouts/slideLayout3.xml pptx/ppt/slideLayouts/slideLayout4.xml pptx/ppt/slideLayouts/slideLayout5.xml pptx/ppt/slideLayouts/slideLayout6.xml pptx/ppt/slideLayouts/slideLayout7.xml pptx/ppt/slideLayouts/slideLayout8.xml pptx/ppt/slideLayouts/slideLayout9.xml pptx/ppt/slideMasters/_rels/slideMaster1.xml.rels pptx/ppt/slideMasters/slideMaster1.xml pptx/ppt/slides/_rels/slide1.xml.rels pptx/ppt/slides/_rels/slide2.xml.rels pptx/ppt/slides/_rels/slide3.xml.rels pptx/ppt/slides/_rels/slide4.xml.rels pptx/ppt/slides/slide1.xml pptx/ppt/slides/slide2.xml pptx/ppt/slides/slide3.xml pptx/ppt/slides/slide4.xml pptx/ppt/tableStyles.xml pptx/ppt/theme/theme1.xml pptx/ppt/theme/theme2.xml pptx/ppt/viewProps.xml sample.lua templates/affiliations.jats templates/article.jats_publishing templates/default.asciidoc templates/default.asciidoctor templates/default.biblatex templates/default.bibtex templates/default.commonmark templates/default.context templates/default.docbook4 templates/default.docbook5 templates/default.dokuwiki templates/default.dzslides templates/default.epub2 templates/default.epub3 templates/default.haddock templates/default.html4 templates/default.html5 templates/default.icml templates/default.jats_archiving templates/default.jats_articleauthoring templates/default.jats_publishing templates/default.jira templates/default.latex templates/default.man templates/default.markdown templates/default.mediawiki templates/default.ms templates/default.muse templates/default.opendocument templates/default.opml templates/default.org templates/default.plain templates/default.revealjs templates/default.rst templates/default.rtf templates/default.s5 templates/default.slideous templates/default.slidy templates/default.tei templates/default.texinfo templates/default.textile templates/default.xwiki templates/default.zimwiki templates/styles.html translations/am.yaml translations/ar.yaml translations/bg.yaml translations/bn.yaml translations/ca.yaml translations/cs.yaml translations/da.yaml translations/de.yaml translations/el.yaml translations/en.yaml translations/eo.yaml translations/es.yaml translations/et.yaml translations/eu.yaml translations/fa.yaml translations/fi.yaml translations/fr.yaml translations/he.yaml translations/hi.yaml translations/hr.yaml translations/hu.yaml translations/is.yaml translations/it.yaml translations/km.yaml translations/ko.yaml translations/lo.yaml translations/lt.yaml translations/lv.yaml translations/nl.yaml translations/no.yaml translations/pl.yaml translations/pt.yaml translations/rm.yaml translations/ro.yaml translations/ru.yaml translations/sk.yaml translations/sl.yaml translations/sq.yaml translations/sr-cyrl.yaml translations/sr.yaml translations/sv.yaml translations/th.yaml translations/tr.yaml translations/uk.yaml translations/ur.yaml translations/vi.yaml translations/zh-Hans.yaml translations/zh-Hant.yaml"

    case "${prev}" in
         --from|-f|--read|-r)
             COMPREPLY=( $(compgen -W "${informats}" -- ${cur}) )
             return 0
             ;;
         --to|-t|--write|-w|-D|--print-default-template)
             COMPREPLY=( $(compgen -W "${outformats}" -- ${cur}) )
             return 0
             ;;
         --email-obfuscation)
             COMPREPLY=( $(compgen -W "references javascript none" -- ${cur}) )
             return 0
             ;;
         --ipynb-output)
             COMPREPLY=( $(compgen -W "all none best" -- ${cur}) )
             return 0
             ;;
         --pdf-engine)
             COMPREPLY=( $(compgen -W "pdflatex lualatex xelatex latexmk tectonic wkhtmltopdf weasyprint prince context pdfroff" -- ${cur}) )
             return 0
             ;;
         --print-default-data-file)
             COMPREPLY=( $(compgen -W "${datafiles}" -- ${cur}) )
             return 0
             ;;
         --wrap)
             COMPREPLY=( $(compgen -W "auto none preserve" -- ${cur}) )
             return 0
             ;;
         --track-changes)
             COMPREPLY=( $(compgen -W "accept reject all" -- ${cur}) )
             return 0
             ;;
         --reference-location)
             COMPREPLY=( $(compgen -W "block section document" -- ${cur}) )
             return 0
             ;;
         --top-level-division)
             COMPREPLY=( $(compgen -W "section chapter part" -- ${cur}) )
             return 0
             ;;
         --highlight-style|--print-highlight-style)
             COMPREPLY=( $(compgen -W "${highlight_styles}" -- ${cur}) )
             return 0
             ;;
         --eol)
             COMPREPLY=( $(compgen -W "crlf lf native" -- ${cur}) )
             return 0
             ;;
         --markdown-headings)
             COMPREPLY=( $(compgen -W "setext atx" -- ${cur}) )
             return 0
             ;;
         *)
             ;;
    esac

    case "${cur}" in
         -*)
             COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
             return 0
             ;;
         *)
             local IFS=$'\n'
             COMPREPLY=( $(compgen -X '' -f "${cur}") )
             return 0
             ;;
    esac

}

complete -o filenames -o bashdefault -F _pandoc pandoc
