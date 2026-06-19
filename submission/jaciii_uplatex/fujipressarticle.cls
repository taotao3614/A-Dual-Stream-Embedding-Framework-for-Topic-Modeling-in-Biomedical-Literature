%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  fujipressarticle.cls  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 
%%%  LaTeX-style-file{
%%%    author          = "Yonetatsu Matsumoto",
%%%    filename        = "fujipressarticle.cls"
%%%    address         = "1-15-7 Uchikanda Chiyoda-ku Tokyo"
%%%    email           = "webmaster@fujipress.jp
%%%    keywords        = "Fuji Technology Press, publisher style",
%%%    docstring       = "This is a LaTeX class file for preparation
%%%                       of submission and final versions of articles
%%%                       to be published in Journals of Fuji Technology Press Ltd.
%%%                       The default font size is 10.5 points.
%%%
%%%    Usage:
%%%        \documentclass{fujipressarticle}
%%%        \begin{document}
%%%        \SetVolume{XX}
%%%        \SetIssueNo{XX}
%%%        \SetPubYear{20XX}
%%%        \setcounter{page}{# of first page} 
%%%        \title{..}
%%%        \author{..}
%%%        \Orcid{..}
%%%        \address{address list}
%%%        \dates{received date}{accepted date}
%%%        \received{received date}
%%%        \accepted{accepted date}
%%%        \markboth{authors in header}{title in header}
%%%        \pagestyle{fujipressstyle}
%%%        \maketitle
%%%        \begin{abstract}{}..\end{abstract}
%%%        \begin{keywords}...\end{keywords}
%%%        ...
%%%        \begin{biography}{Author's name}...\end{biography}
%%%        \end{document}
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Development log
%%% v1.0 ..... First version derived from of jaciiiarticle.cls
%%% v1.1 ..... gentombow added. CCBY, instituteoverview options added.  kcatcode`°=15 added 2022/3/25
%%% v1.2 ..... compatible with diagbox 2022/7/22
%%% v1.3 ..... cite.sty instead of citesort.sty 2022/9/26
%%% v1.6 ..... add reprinteven option 2023/1/5
%%% v1.7 ..... bold fase in $...$ envirounment 2024/5/31
%%% ===========================================================================
\typeout{Document Class `fujipressarticle' v1.7 <May 31, 2024>}
\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{fujipressarticle}[2024/05/31 revision v1.7 by Fuji Technology Press Ltd.]

\usepackage{mathptmx,calc,type1cm,amsmath,siunitx} 
\usepackage{newtxtext,newtxmath}
\usepackage [hyphens]{url}
\renewcommand\UrlFont{\rmfamily}

\kcatcode`°=15 %%<= is not a CJK character

\newcommand\jtoday{\the\year/\the\month/\the\day}
\newcommand\@ptsize{}
\newif\if@restonecol
\newif\if@titlepage      \@titlepagefalse
\newif\if@draftclsmode   \@draftclsmodefalse
\newif\if@technote       \@technotefalse
\newif\if@editorialtwocolumn \@editorialtwocolumnfalse %for Editorial twocolumn

%%% Japanese Environment
\newif\if@langJapanese \@langJapanesefalse %
\def\Japanese{Japanese}\gdef\@languageOut{English}%
\newcommand\articlelanguage[1]{\renewcommand{\@languageOut}{#1}\ifx\@languageOut\Japanese\@langJapanesetrue\fi}
%%%%%

\input{fujipressfont.clo} % 直接記述の場合は \endinputを除く

% uses a4paper
\setlength\paperheight{297mm}%
\setlength\paperwidth {597.6pt}%{210mm}

% default: Times New Roman font

% These three commands are the entire times.sty package.
\renewcommand{\sfdefault}{phv}
\renewcommand{\rmdefault}{ptm}
\renewcommand{\ttdefault}{pcr}
\normalfont\selectfont

% set sizes and margins
% The textwidth is 21 pica (1 pica = 12pt). They have a colsep of 1 pica.
\setlength\topmargin{-1.0in}  
\addtolength{\topmargin}{16.14pt}

\setlength\textheight{708.45pt}     
\setlength\textwidth{502pt}% 2 x 20pc + 20pt = 500pt

\setlength\columnsep{20pt}

\setlength\oddsidemargin{-23.5pt} 
\setlength\evensidemargin{-23.5pt}

\setlength\parindent{10.5pt}
\setlength\headsep{20.56pt}
\setlength\headheight{20pt}

%%%%% Adjusting the space around '=' in eqnarray environment
\newlength{\eqarcolsep}
\newdimen{\eqarcolsep}
\eqarcolsep=0.14em

% Controls the amount of EXTRA spacing above and below \trivlist 
% Both \list and IED lists override this.
% However, \trivlist will use this as will most things built from \trivlist like the \center environment.
\topsep           1.3ex

\partopsep          \z@

% Controls the spacing between paragraphs in lists. 
% JACIII does not increase spacing before or after paragraphs so this is also zero. 
% With jaciiiarticle.cls, global changes to this value DO affect lists (but not IED lists).
\parsep             \z@

% Controls the extra spacing between list items. JACIII does not put extra spacing between items.
% With jaciiiarticle.cls, global changes to this value DO affect lists (but not IED lists).
\itemsep            \z@

\itemindent         -1em


\DeclareOption{twoside}{\@twosidetrue  \@mparswitchtrue}


\DeclareOption{draft}{\setlength\overfullrule{5pt}}% If the user selects draft, then this class AND any packages will go into draft mode.
\DeclareOption{draftclsmode}{\@draftclsmodetrue}% draftcls is for a draft mode which will not affect any packages used by the document.
\DeclareOption{final}{\setlength\overfullrule{0pt}}

\DeclareOption{titlepage}{\@titlepagetrue}
\DeclareOption{notitlepage}{\@titlepagefalse}

\DeclareOption{twocolumn}{\@twocolumntrue}
\DeclareOption{editorialtwocolumn}{\@editorialtwocolumntrue}%for Editorial twocolumn

\DeclareOption{technote}{\@technotetrue}  % sets variable for techn. note

\def\form{Paper:}%% default value of \form is Paper:, this is refered in \@maketitle

%%%% Declare option for article kind
\newif\if@development \@developmentfalse
\newif\if@disasterletter \@disasterletterfalse%Dr
\newif\if@disasterreport \@disasterreportfalse%Dr
\newif\if@discussion \@discussionfalse
\newif\if@editorial \@editorialfalse
\newif\if@factory \@factoryfalse%Au
\newif\if@interview \@interviewfalse%Au
\newif\if@invitedpaper \@invitedpaperfalse%Jc
\newif\if@letter \@letterfalse
\newif\if@material \@materialfalse
\newif\if@news \@newsfalse
\newif\if@note \@notefalse
\newif\if@paper \@paperfalse
\newif\if@researchpaper \@researchpaperfalse
\newif\if@position \@positionfalse%Au
\newif\if@report \@reportfalse%Au
\newif\if@review \@reviewfalse
\newif\if@shortpaper \@shortpaperfalse%Jc
\newif\if@survey \@surveyfalse
\newif\if@technical \@technicalfalse%Au
\newif\if@topic \@topicfalse%Au
\newif\if@tutorial \@tutorialfalse
\newif\if@overview \@overviewfalse%Rb
\DeclareOption{development}{\@developmenttrue \def\form{Development Report:}\gdef\@articlekindOut{Development Report}}
\DeclareOption{disasterletter}{\@disasterlettertrue \def\form{Disaster Letter:}\gdef\@articlekindOut{Disaster Letter}}%Dr
\DeclareOption{disasterreport}{\@disasterreporttrue \def\form{Disaster Report:}\gdef\@articlekindOut{Disaster Report}}%Dr
\DeclareOption{discussion}{\@discussiontrue \def\form{Discussion:}\gdef\@articlekindOut{Discussion}}
\DeclareOption{editorial}{\@editorialtrue \def\form{Editorial for Special Issue}\gdef\@articlekindOut{Editorial}}
\DeclareOption{factory}{\@factorytrue \def\form{Factory Tour:}\gdef\@articlekindOut{Factory Tour}}%Au
\DeclareOption{interview}{\@interviewtrue \def\form{Interview:}\gdef\@articlekindOut{Interview}}%Au
\DeclareOption{invitedpaper}{\@invitedpapertrue \def\form{Invited Paper:}\gdef\@articlekindOut{Invited Paper}}%Jc
\DeclareOption{letter}{\@lettertrue \def\form{Letter:}\gdef\@articlekindOut{Letter}}
\DeclareOption{material}{\@materialtrue \def\form{Material:}\gdef\@articlekindOut{Material}}
\DeclareOption{news}{\@newstrue \def\form{News:}\gdef\@articlekindOut{News}}
\DeclareOption{note}{\@notetrue \def\form{Note:}\gdef\@articlekindOut{Note}}
\DeclareOption{paper}{\@papertrue \def\form{Paper:}\gdef\@articlekindOut{Paper}}
\DeclareOption{researchpaper}{\@papertrue \def\form{Research Paper:}\gdef\@articlekindOut{Research Paper}}
\DeclareOption{position}{\@positiontrue \def\form{Position Paper:}\gdef\@articlekindOut{Position Paper}}%Au
\DeclareOption{report}{\@reporttrue \def\form{Report:}\gdef\@articlekindOut{Report}}%Au
\DeclareOption{review}{\@reviewtrue \def\form{Review:}\gdef\@articlekindOut{Review}}
\DeclareOption{shortpaper}{\@shortpapertrue \def\form{Short Paper:}\gdef\@articlekindOut{Short Paper}}%Jc
\DeclareOption{survey}{\@surveytrue \def\form{Survey Report:}\gdef\@articlekindOut{Survey Report}}
\DeclareOption{technical}{\@technicaltrue \def\form{Technical Paper:}\gdef\@articlekindOut{Technical Paper}}%Au
\DeclareOption{topic}{\@topictrue \def\form{Topic:}\gdef\@articlekindOut{Topic}}%Au
\DeclareOption{tutorial}{\@tutorialtrue \def\form{Tutorial:}\gdef\@articlekindOut{Tutorial}}
\DeclareOption{instituteoverview}{\@overviewtrue \def\form{Institute Overview:}\gdef\@articlekindOut{Institute Overview}}%Rb


%%%% branching variable to different journals define journal identifer valid throughout this class file
\def\@journal{0}%%default(0:jaciii, 1:jrm, 2:jdr, 3:ijat add new journal here,...)
\DeclareOption{JACIII}{\def\@journal{0}}%JACIII
\DeclareOption{JRM}{\def\@journal{1}}%JRM
\DeclareOption{JDR}{\def\@journal{2}}%JDR
\DeclareOption{IJAT}{\def\@journal{3}}%IJAT%%% _ym
%DeclareOption{NewJournal}{\def\@journal{journal identifer number}}

%%%% variation for Creative Commons
\def\@CreativeCommons{1}%%default(1:CC BY-ND, 0:CC BY )
\DeclareOption{CCBY}{\def\@CreativeCommons{0}}%CC BY
\DeclareOption{CCBYND}{\def\@CreativeCommons{1}}%CC BY-ND


%%%% output configuration for respective style 
\newif\if@referee \@refereefalse %% referee style(neither author name nor profile)
\newif\if@authorproof \@authorprooffalse %% authorproofing style(authorproof style, no doi no CC)
\newif\if@publish \@publishfalse %% publishing style(Publish style, everything included)

\newif\if@volumeNumber \@volumeNumberfalse %%volumeNumber output
\newif\if@dates  \@datesfalse %%dates output
%_ym 2021
\newif\if@received  \@receivedfalse %%received output
\newif\if@accepted  \@acceptedfalse %%accepted output
\newif\if@volume  \@volumefalse %%volume output
\newif\if@issueNo \@issueNofalse %%issueNo output
\newif\if@pubYear \@pubYearfalse %%pubYear output

\newif\if@author  \@authortrue %%author output
\newif\if@address \@addressfalse %%address output
\newif\if@editors \@editorsfalse %%editors output for editorial

\newif\if@doubleskip \@doubleskipfalse %%double baselineskip for proof readers  
\newif\if@header \@headertrue %%header output
\newif\if@footer \@footertrue %%footer output
\newif\if@reference \@referencetrue %%reference output
\newif\if@profile \@profilefalse %%profile output

\DeclareOption{referee}{\@authorfalse \@headerfalse \@footerfalse \@profilefalse}
\DeclareOption{proof}{\@doubleskiptrue \@profiletrue \@referencefalse}
\DeclareOption{authorproof}{\@authorprooftrue\@profiletrue}
\DeclareOption{publish}{\@profiletrue}
%%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

%%%% Declare option for reprinteven
\newif\if@reprinteven \@reprintevenfalse
\DeclareOption{reprinteven}{\@reprinteventrue}%reprint starting with even page

\DeclareOption{openbib}{%
  \AtEndOfPackage{%
    \renewcommand\@openbib@code{%
      \advance\leftmargin\bibindent
      \itemindent -\bibindent
      \listparindent \itemindent
      \parsep \z@
      }%
    \renewcommand\newblock{\par}}%
}

\ExecuteOptions{a4paper,twocolumn,twoside,final,openright}

\ProcessOptions\relax

% \@options
%%%% For editorial mode 
\if@editorial
 \if@editorialtwocolumn\else\@twocolumnfalse\fi
\else\fi

\setlength\lineskip{1\p@}
\setlength\normallineskip{1\p@}
\renewcommand\baselinestretch{}

\if@doubleskip%%%% definition of baselineskip
    \renewcommand\baselinestretch{2.5}
\fi

\parskip 0pt

\@lowpenalty   51
\@medpenalty  151
\@highpenalty 301
\setcounter{topnumber}{2}

\renewcommand\topfraction{1.0}
\setcounter{bottomnumber}{2}
\renewcommand\bottomfraction{.4}
\setcounter{totalnumber}{4}
\renewcommand\textfraction{.2}
\renewcommand\floatpagefraction{.8}
\setcounter{dbltopnumber}{4}
\renewcommand\dbltopfraction{1.0}
\renewcommand\dblfloatpagefraction{.8}

%%% Adjusted the float parameter for big float
\def\bigfloat{
    \renewcommand{\topfraction}{1.0}
    \renewcommand{\bottomfraction}{1.0}
    \renewcommand{\textfraction}{0.0}
    \setlength{\dbltextfloatsep}{0pt}
    \setlength{\dblfloatsep}{0pt}
}

%%% Add Index Tab for Special Issue,General Papeper, etc. 
\newif\if@IndexTab\@IndexTabfalse%
\newcommand{\SetIndexTab}[1]{\@IndexTabtrue\SetTabvoffset{#1}}%
\newcommand{\setnewlength}[2]{\newlength{#1}\setlength{#1}{#2}}%

%% define tab rule
\setnewlength{\tabwidth}{0.3cm}% Tab width in paper 
\setnewlength{\tabheight}{1.5cm}% Tab height 
\setnewlength{\tabpaperout}{0.5cm}% Tab lenght out of paper width
\setnewlength{\tabboxwidth}{\tabwidth}%
\advance\tabboxwidth by \tabpaperout% Printed tab box width
\def\indextabrule{\vbox{\hrule width\tabboxwidth height\tabheight}}

%% culculate horizontal distance from textarea start point to tab start point for even page and odd page
\setnewlength{\defaultmargin}{1in}%
\setnewlength{\@@epto}{0pt}% temp register
\advance\@@epto by \defaultmargin%
\advance\@@epto by \evensidemargin%
\setnewlength{\@epto}{-\@@epto}%
\advance\@epto by -\tabpaperout%
\setnewlength{\evenpagetabhoffset}{\@epto}%
\setnewlength{\@@opto}{\paperwidth}%
\advance\@@opto by -\defaultmargin%
\advance\@@opto by -\oddsidemargin%
\advance\@@opto by -\tabwidth%
\setnewlength{\@opto}{\@@opto}%
\setnewlength{\oddpagetabhoffset}{\@opto}%
%
%% defined vertical distance from header top point to tab start point for each term
\setnewlength{\@tmplength}{\tabheight}\advance\@tmplength by \headsep%
%
\def\@specialissue{specialissue}% for Special Issue page
\setnewlength{\tabvoffset@specialissue}{\@tmplength}% 
\def\@generalarticle{generalarticle}% for General Article page
\advance\@tmplength by \tabheight%
\setnewlength{\tabvoffset@generalarticle}{\@tmplength}%
\def\@review{review}% for Review Page
\advance\@tmplength by \tabheight%
\setnewlength{\tabvoffset@review}{\@tmplength}%
\def\@rghigh{rghigh}% for Regular-high
\advance\@tmplength by \tabheight%
\setnewlength{\tabvoffset@rghigh}{\@tmplength}%
\def\@rgmiddle{rgmiddle}% for Regular-middle
\advance\@tmplength by \tabheight%
\setnewlength{\tabvoffset@rgmiddle}{\@tmplength}%
\def\@rglow{rglow}% for Regular-low
\advance\@tmplength by \tabheight%
\setnewlength{\tabvoffset@rglow}{\@tmplength}%
%
%% setting vertical tab offset
\def\SetTabvoffset#1{%
  \def\@issuekind{#1}%
  % setting vertical tab offset
  \ifx\@issuekind\@specialissue\def\tabvoffset{\tabvoffset@specialissue}
  \else%
    \ifx\@issuekind\@generalarticle\def\tabvoffset{\tabvoffset@generalarticle}% 
    \else%
      \ifx\@issuekind\@review\def\tabvoffset{\tabvoffset@review}% 
      \else%
        \ifx\@issuekind\@rghigh\def\tabvoffset{\tabvoffset@rghigh}% 
        \else%
          \ifx\@issuekind\@rgmiddle\def\tabvoffset{\tabvoffset@rgmiddle}% 
          \else%
            \ifx\@issuekind\@rglow\def\tabvoffset{\tabvoffset@rglow}% 
            \else%
            \@IndexTabfalse
            \fi%
          \fi%
        \fi%
      \fi%
    \fi%
  \fi%
}%
%
%Tab Output
\def\drawIndexTab{%
  % setting horizontal tab offset
  \ifodd\c@page\def\tabhoffset{\oddpagetabhoffset}%
  \else%
   \def\tabhoffset{\evenpagetabhoffset}%
  \fi%
%
  \fpmoveto{\tabhoffset}{\tabvoffset}{\indextabrule}   
}%

%%% BEGIN define \fpmovoto command %%%%%%% 2022/07/22
\newbox\@pagerule
\def\fphmoveto#1#2{% define horizontal move for box
  \setbox\@pagerule=\hbox{#2}\wd\@pagerule=\z@
  \hbox to \z@{\hskip#1\box\@pagerule\hss}
}
\def\fpvmoveto#1#2{% define vartical move for box
  \ifvmode\leavemode\fi%
  \setbox\@pagerule=\hbox{#2}\ht\@pagerule=\z@\dp\@pagerule=\z@
  \vbox to \z@{\vskip#1\box\@pagerule\vss}
}
\def\fpmoveto#1#2#3{\fphmoveto{#1}{\fpvmoveto{#2}{#3}}}
%%%%% END define \movoto command %%%%%%%
%
%%%%%%%%%%%%%%%%  END of Index Tab out Define %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newif\if@articleID\@articleIDfalse
\newcommand{\SetArticleID}[1]{\def\ArticleID{#1}\@articleIDtrue}

\newcommand{\SetVolumeNumber}[1]{\def\VolumeNumber{#1}\@volumeNumbertrue}
\newcommand{\SetVolume}[1]{\def\Volume{#1}\@volumetrue}
\newcommand{\SetIssueNo}[1]{\def\IssueNo{#1}\@issueNotrue}
\newcounter{vol}
\newcommand{\SetPubYear}[1]{\def\PubYear{#1}\@pubYeartrue\c@vol=#1}

%%Journal dependent　_ym 2021/08/27
\ifcase \@journal
  %%  %%JACIII
    \def\jo@doi{jaciii}
    \def\footer@gap{17pt}
    \def\otmp@jofoottp{\mbox{\hbox to 85pt{\if@volumeNumber\VolumeNumber\fi\hfill}\hbox to 332pt{\hfill Journal of Advanced Computational Intelligence and Intelligent Informatics\hfill}\hbox to 85pt{\hfill\thepage}}\\}
    \def\etmp@jofoottp{\mbox{\hbox to 85pt{\thepage\hfill}\hbox to 332pt{\hfill Journal of Advanced Computational Intelligence and Intelligent Informatics\hfill}\hbox to 85pt{\hfill\if@volumeNumber\VolumeNumber\fi}}\\}
    \def\otmp@jofoot{\begin{minipage}{\textwidth}%
        \mbox{\hbox to 85pt{\if@volumeNumber\VolumeNumber\fi\hfill}\hbox to 332pt{\hfill Journal of Advanced Computational Intelligence\hfill}\hbox to 85pt{\hfill\thepage}}\\%
        \hfil and Intelligent Informatics\hfil
      \end{minipage}}
    \def\etmp@jofoot{\begin{minipage}{\textwidth}
        \mbox{\hbox to 85pt{\thepage\hfill}\hbox to 332pt{\hfill Journal of Advanced Computational Intelligence\hfill}\hbox to 85pt{\hfill\if@volumeNumber\VolumeNumber\fi}}\\%
        \hfil and Intelligent Informatics\hfil%
      \end{minipage}}
    \newcommand\ssubsubsection{\@startsection{subsubsection}{3}{\z@}{3.5ex \@plus 1.5ex \@minus 1.5ex}{0.7ex \@plus 0.5ex \@minus 0ex}{\normalfont\normalsize}}
    \def\pro@career{Brief Biographical History:}
    \def\pro@publications{Main Works:}
    \def\pro@societies {Membership in Academic Societies:}

  \or %%JRM
    \def\jo@doi{jrm}
    \def\footer@gap{25pt}
    \def\otmp@jofoottp{Journal of Robotics and Mechatronics \if@volumeNumber\VolumeNumber\fi\hfill\thepage\\}%
    \def\etmp@jofoottp{\thepage\hfill Journal of Robotics and Mechatronics \if@volumeNumber\VolumeNumber\fi\\}
    \def\otmp@jofoot{\hbox to\textwidth{\otmp@jofoottp}}
    \def\etmp@jofoot{\hbox to\textwidth{\etmp@jofoottp}}
    \newcommand\ssubsubsection{\@startsection{subsubsection}{3}{\z@}{3.5ex \@plus 1.5ex \@minus 1.5ex}{0.7ex \@plus 0.5ex \@minus 0ex}{\normalfont\normalsize\bfseries}}
    \def\pro@career{Brief Biographical History:}
    \def\pro@publications{Main Works:}
    \def\pro@societies {Membership in Academic Societies:}

  \or %%JDR
    \def\jo@doi{jdr}
    \def\footer@gap{25pt}
    \def\otmp@jofoottp{Journal of Disaster Research \if@volumeNumber\VolumeNumber\fi\hfill\thepage\\}%
    \def\etmp@jofoottp{\thepage\hfill Journal of Disaster Research \if@volumeNumber\VolumeNumber\fi\\}
    \def\otmp@jofoot{\hbox to\textwidth{\otmp@jofoottp}}
    \def\etmp@jofoot{\hbox to\textwidth{\etmp@jofoottp}}
    \newcommand\ssubsubsection{\@startsection{subsubsection}{3}{\z@}{3.5ex \@plus 1.5ex \@minus 1.5ex}{0.7ex \@plus 0.5ex \@minus 0ex}{\normalfont\normalsize\bfseries}}
    \def\pro@career{Brief Career:}
    \def\pro@publications{Selected Publications:}
    \def\pro@societies {Academic Societies \& Scientific Organizations:}

  \or %%IJAT
    \def\jo@doi{ijat}
    \def\footer@gap{25pt}
    \def\otmp@jofoottp{Int. J. of Automation Technology \if@volumeNumber\VolumeNumber\fi\hfill\thepage\\}%
    \def\etmp@jofoottp{\thepage\hfill Int. J. of Automation Technology \if@volumeNumber\VolumeNumber\fi\\}
    \def\otmp@jofoot{\hbox to\textwidth{\otmp@jofoottp}}
    \def\etmp@jofoot{\hbox to\textwidth{\etmp@jofoottp}}
    \newcommand\ssubsubsection{\@startsection{subsubsection}{3}{\z@}{3.5ex \@plus 1.5ex \@minus 1.5ex}{0.7ex \@plus 0.5ex \@minus 0ex}{\normalfont\normalsize\bfseries}}
    \def\pro@career{Brief Biographical History:}
    \def\pro@publications{Main Works:}
    \def\pro@societies {Membership in Academic Societies:}

  \else %%exception -> none
\fi

%%SetVolumeNumber 
\if@volumeNumber
%Vol, No, Year from VolumeNumber
\else
  \def\VolumeNumber{Vol.\Volume\ No.\IssueNo, \PubYear}\@volumeNumbertrue
\fi

%%doi _ym 2021/08/27
\def\@doi#1#2{  
  \ifnum \thepage<10%page 1 digit
    https://doi.org/10.20965/#1.#2.p000\thepage%
  \else{\ifnum\thepage<100%page 2 digit
        https://doi.org/10.20965/#1.#2.p00\thepage%
    \else {\ifnum \thepage<1000%page 3 digit
        https://doi.org/10.20965/#1.#2.p0\thepage%
      \else {%
        https://doi.org/10.20965/#1.#2.p\thepage%
      }\fi
    }\fi
  }\fi
}

\newcounter {section}
\newcounter {subsection}[section]
\newcounter {subsubsection}[subsection]
\newcounter {paragraph}[subsubsection]
\newcounter {subparagraph}[paragraph]

\renewcommand\thesection      {\@arabic\c@section}
\renewcommand\thesubsection   {\thesection.\@arabic\c@subsection}
\renewcommand\thesubsubsection{\thesubsection.\@arabic\c@subsubsection}

%% Creative Commons _ym 2022/03/08
\ifcase \@CreativeCommons
  %%  %%CC BY
    \def\cc@kind{CC BY}
    \def\cc@img{by.eps}
    \def\cc@str{Attribution 4.0 International}
    \def\cc@url{https://creativecommons.org/licenses/by/4.0/}

  \or %%CC BY-ND
    \def\cc@kind{CC BY-ND}
    \def\cc@img{by-nd.eps}
    \def\cc@str{Attribution-NoDerivatives 4.0 International}
    \def\cc@url{https://creativecommons.org/licenses/by-nd/4.0/}

  \else %%exception -> none
\fi

%% Creative Commons
\def\cc@footer{%
  \hspace{3pt}
}

%% Title Page
\def\ps@titlepagestyle{
  \if@header
    \def\@oddhead{
      \if@IndexTab{\hbox to \z@{\drawIndexTab}}\else\fi
      \begin{minipage}{\textwidth}
        \fontsize{10pt}{10pt}\selectfont  
        \if@authorproof% authorproof mode 
          \hspace{3pt}
        \else
          \begin{flushright}\hfill \vtop{\hsize=300pt \@doi{\jo@doi}{\PubYear}} \end{flushright}
        \fi
      \end{minipage}
    }
    \def\@evenhead{\@oddhead}
  \fi%%end of if@header

  \if@draftclsmode 
    \def\@oddfoot{\scriptsize \@date\hfil DRAFT}
    \def\@evenfoot{\scriptsize DRAFT\hfil \@date}
  \else % not draft class mode  
	  \if@footer
      \def\otmp@foot{\begin{minipage}{\textwidth}\vspace{\footer@gap}\otmp@jofoottp\cc@footer\end{minipage}}%vspace本文との間隔調整
      \def\etmp@foot{\begin{minipage}{\textwidth}\vspace{\footer@gap}\etmp@jofoottp\cc@footer\end{minipage}}
      
      \if@reprinteven
        \def\@oddfoot{\etmp@foot}
        \def\@evenfoot{\otmp@foot}
      \else
        \def\@oddfoot{\otmp@foot}%normal
        \def\@evenfoot{\etmp@foot}%normal
      \fi
	  \fi%
  \fi%
} %% end of ps@titlepage

\def\ps@fujipressstyle{
  \if@header%
    \def\otmp@head{ 
      \if@IndexTab{\hbox to \z@{\drawIndexTab}}\else\fi%
      \begin{minipage}{498pt}%500pt will be error
        \renewcommand\baselinestretch{1}
        \fontsize{9pt}{10pt}\selectfont  
        \begin{flushright}\hfill \vtop{\hsize=300pt \rightmark} \end{flushright}
        \normalfont
      \end{minipage}
    }
    \def\etmp@head{%
      \if@IndexTab{\hbox to \z@{\drawIndexTab}}\else\fi%
      \begin{minipage}{498pt}
        \renewcommand\baselinestretch{1}
        \fontsize{9pt}{10pt}\selectfont  
        \begin{flushleft} \vtop{\hsize=300pt \leftmark}\hfill \end{flushleft}
        \normalfont
      \end{minipage}
    }

    \if@reprinteven
      \def\@oddhead{\etmp@head}
      \def\@evenhead{\otmp@head}
    \else
      \def\@oddhead{\otmp@head}%normal
      \def\@evenhead{\etmp@head}%normal
    \fi
  \fi%%end of if@header
  
  \if@footer%%footer
    \if@reprinteven
      \def\@oddfoot{\etmp@jofoot}
      \def\@evenfoot{\otmp@jofoot}
    \else
      \def\@oddfoot{\otmp@jofoot}%normal
      \def\@evenfoot{\etmp@jofoot}%normal
    \fi
  \else
    \def\@oddfoot{DRAFT \hfil \thepage}
    \def\@evenfoot{DRAFT \hfil \thepage}
  \fi%
} % end of fujipresspagestyle

\newcommand\maketitle{\par%
  \begingroup
  \renewcommand\thefootnote{} % the \thanks{} mark type is empty
  \if@editorial%%for editorial
      \if@editorialtwocolumn\twocolumn[\@maketitle]%
      \else\global\@topnum\z@ \@maketitle
      \fi%
  \else
      \if@twocolumn
          \if@technote   
            \newpage\global\@topnum\z@ \@maketitle
          \else\twocolumn[\@maketitle]              
          \fi
      \else\newpage\global\@topnum\z@ \@maketitle 
      \fi
  \fi
  \thispagestyle{titlepagestyle}\@thanks
  \endgroup
  \setcounter{footnote}{0}\let\maketitle\relax\let\@maketitle\relax

  %%%%Modefied for Editorial start
  \if@editorial
      \gdef\@thanks{}\gdef\@title{}%
  \else
      \gdef\@thanks{}\gdef\@author{}\gdef\@title{}%
  \fi
  %%%%Modefied for Editorial end
  \let\thanks\relax
  \if@draftclsmode \vfil\mbox{}\newpage\fi
}

\newcommand{\address}[1]{\newcommand{\@address}[1]{#1}\@addresstrue}
\newcommand{\dates}[2]{%
  \newcommand{\d@received}[1]{#1}\newcommand{\d@accepted}[1]{#2}\@datestrue%
  \if#2\empty\else\@acceptedtrue\fi
  \gdef\@receiveOut{#1}\gdef\@acceptOut{#2}%
}
\newcommand{\received}[1]{\let\d@received\relax\newcommand{\d@received}[1]{#1}\@receivedtrue\@datesfalse}
\newcommand{\accepted}[1]{%
  \if#1\empty\else\@acceptedtrue\fi
  \let\d@accepted\relax\newcommand{\d@accepted}[1]{#1}\@datesfalse
}

%% Define @maketitle
\if@editorial
  \newcommand\editors[1]{\newcommand{\@@editors}{\expandafter#1}\@editorstrue}
  \def\editor#1#2{%
    \renewcommand{\author}[1]{\fontsize{12pt}{14pt}\bfseries{##1}\normalfont}%
    \renewcommand{\address}[1]{\parbox[t]{#1}{\fontsize{8pt}{11.5pt}\selectfont{##1}\normalfont} }%
    \parbox[t]{#1}{\centering\expandafter#2}%
  }%
  \def\@maketitle{\newpage%
    \if@doubleskip\renewcommand\baselinestretch{1}\fi%reset baseline skip
    \if@draftclsmode\mbox{}\vfil\fi%
    \begin{center}
    \vspace*{-1pt}%%16.14pt(topmargin)+19pt(headheight)+20.56pt(headsep)-56.7(``Paper:'' from the paper top edge)
    \begin{flushleft}
      {\fontsize{10pt}{11.12pt}\selectfont \textbf{%
          \form \if@articleID\hspace*{.5em}\ArticleID\fi}\normalfont}
    \end{flushleft}
          \vspace*{10mm}%
    \vskip0.2em{\fontsize{18pt}{20pt}\bfseries\@title\par\normalfont}\vskip1.0em%Draw title
    \if@editors\@@editors\else\fi
    \end{center}
  %  \if@technote
  %  \else
    \vspace*{22.98pt} %% from [Received:....] to the main text field 
  %  \fi
  } %% end of maketitle for editorial
\else
  %% title of normal article
  \def\@maketitle{\newpage%
    \if@doubleskip\renewcommand\baselinestretch{1}\fi%reset baseline skip
    \if@draftclsmode\mbox{}\vfil\fi%
    \begin{center}
    \if@technote
      {\textbf{\Large\@title}\par}\vskip 1.3em {\lineskip .5em\begin{tabular}[t]{c}\@author\end{tabular}\@specialpapernotice\par}
    \else
      \vspace*{-1pt}%%16.14pt(topmargin)+19pt(headheight)+20.56pt(headsep)-56.7(``Paper:'' from the paper top edge)
      \begin{flushleft}
        {\fontsize{10pt}{11.12pt}\selectfont \textbf{%
            \form \if@articleID\hspace*{.5em}\ArticleID\fi}\normalfont}
      \end{flushleft}
      \vskip0.2em{\fontsize{18pt}{20pt}\bfseries\@title\par\normalfont}\vskip1.0em%Draw title
      
      \if@author%
        {%
          \lineskip0.5em\fontsize{12pt}{14pt}{\bfseries
            \begin{tabular}[t]{c}
            \@author%
            \normalfont\end{tabular}%
          }\\%
          \vspace*{8pt}%
          {%
            \if@address%
              \fontsize{8pt}{11.5pt}\selectfont\@address{} \par%
            \fi%end of if@address
            \if@dates%
              \if@accepted%
                [Received \d@received{}; accepted \d@accepted{}]%
              \else
                [Received \d@received{}]%
              \fi
            \else
              \if@received%_ym
                [Received \d@received{}%
              \fi%
              \if@accepted%
                ; accepted \d@accepted{}]%
              \else
                \relax
              \fi%
            \fi%end of \if@dates
            \normalfont%
          }%
          \@specialpapernotice\par%
        }%
      \fi%End of if@author
    \fi%End of if@technote??
    \end{center}
    \if@technote
    \else
    \vspace*{22.98pt} %% from [Received:....] to the main text field 
    \fi
  } %% end of maketitle for normal article
\fi

\if@technote
  \setcounter{secnumdepth}{3}
\else
  \setcounter{secnumdepth}{4}
\fi


\renewcommand\theparagraph    {\@alph\c@paragraph}
\renewcommand\thesubparagraph {\@alpha\c@subparagraph}

\newcommand\ssection{\@startsection {section}{1}{\z@}
                                    {23pt} % \@plus 1.5ex \@minus 1.5ex}%
                                    {11pt} % \@plus 1ex   \@minus 0ex}%
                                    {\normalfont\fontsize{12pt}{14pt}\bfseries}}

\newcommand\ssubsection{\@startsection{subsection}{2}{\z@}%
                                     {3.5ex \@plus 1.5ex \@minus 1.5ex}%
                                     {0.7ex \@plus 0.5ex \@minus 0ex}%
                                     {\normalfont\fontsize{11pt}{13pt}\bfseries}}

\newcommand\sparagraph{\@startsection{paragraph}{4}{\parindent}%
                                     {0ex \@plus 0.1ex \@minus 0.1ex}%
                                     {0ex}%
                                     {\normalfont\normalsize\itshape}}

\newcommand\section[1]{\ssection{\hspace{-11pt}.\hspace{5pt}#1}}
\newcommand\subsection[1]{\ssubsection{\hspace{-11pt}.\hspace{5pt}#1}}
\newcommand\subsubsection[1]{\ssubsubsection{\hspace{-11pt}.\hspace{5pt}#1}}
\newcommand\paragraph[1]{\sparagraph{\hspace{-11pt}.\hspace{5pt}#1}}

\newcommand\sacknowledgments{\@startsection {0}{1}{\z@}
                                    {23pt} % \@plus 1.5ex \@minus 1.5ex}%
                                    {2pt} % \@plus 1ex   \@minus 0ex}%
                                    {\normalfont\small\bfseries}}
\newcommand\acknowledgments[1][Acknowledgments]{\sacknowledgments*{#1}\small\noindent}

% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

% we retain this stuff from the older jaciiiarticle.cls so that \list will work the same way as before. 
% However, itemize, enumerate and description (IED) could care less about what these are as they all are overridden.
\setlength\leftmargin    {2.0em}
\setlength\leftmargini   {2.0em}
\setlength\leftmarginii  {1.0em}
\setlength\leftmarginiii {1.5em}
\setlength\leftmarginiv  {1.5em}
\setlength\leftmarginv   {1.0em}
\setlength\leftmarginvi  {1.0em}

\setlength\labelsep  {5pt}
\setlength\labelwidth{\z@}

\@beginparpenalty -\@lowpenalty
\@endparpenalty   -\@lowpenalty
\@itempenalty     -\@lowpenalty

\renewcommand\theenumi   {\@arabic\c@enumi}
\renewcommand\theenumii  {\@alph\c@enumii}
\renewcommand\theenumiii {\@roman\c@enumiii}
\renewcommand\theenumiv  {\@Alph\c@enumiv}

\newcommand\labelenumi   {\theenumi.}
\newcommand\labelenumii  {\theenumii.}
\newcommand\labelenumiii {\theenumiii.}
\newcommand\labelenumiv  {\theenumiv.}

\renewcommand\p@enumii{\theenumi}
\renewcommand\p@enumiii{\theenumi(\theenumii)}
\renewcommand\p@enumiv{\p@enumiii\theenumiii}

\newcommand\labelitemi{$\scriptstyle\bullet$}
\newcommand\labelitemii{\textbfseries{--}}
\newcommand\labelitemiii{$\ast$}
\newcommand\labelitemiv{$\cdot$}

\newcommand\jaciiitransversionmajor{1}
\newcommand\jaciiitransversionminor{5}

\newdimen\jaciiiilabelindentA
\newdimen\jaciiiilabelindentB
\newdimen\jaciiiilabelindent
\newdimen\jaciiielabelindent
\newdimen\jaciiidlabelindent
\newdimen\labelindent

\jaciiiilabelindentA \parindent
\jaciiiilabelindentB 1.3\parindent
\jaciiiilabelindent  \jaciiiilabelindentA
\jaciiielabelindent  \parindent
\jaciiidlabelindent  \parindent
\labelindent         \parindent

\newdimen\jaciiiiednormlabelsep
\newdimen\jaciiiiedmathlabelsep
\newdimen\jaciiiiedtopsep

\jaciiiiednormlabelsep 0.6em
\jaciiiiedmathlabelsep 1.2em
\jaciiiiedtopsep       0.3ex

\newcommand\jaciiilabelindentfactori{1.0}   % almost always one
\newcommand\jaciiilabelindentfactorii{0.75} % 0.0 or 1.0 may be used in some cases
\newcommand\jaciiilabelindentfactoriii{0.0} % 0.75? 0.5? 0.0?
\newcommand\jaciiilabelindentfactoriv{0.0}
\newcommand\jaciiilabelindentfactorv{0.0}
\newcommand\jaciiilabelindentfactorvi{0.0}
\newcommand\labelindentfactor{1.0}

%%%%________ new enumerate/itemize environment ______________________________
\def\enumerate{%
  \ifnum \@enumdepth >\thr@@\@toodeep\else
    \advance\@enumdepth\@ne
    \edef\@enumctr{enum\romannumeral\the\@enumdepth}%
    \expandafter
    \list
      \csname label\@enumctr\endcsname
      {\usecounter\@enumctr\def\makelabel##1{\hss\llap{##1}}}%
  \fi}
\let\endenumerate =\endlist
\newcount\@itemdepth \@itemdepth = 0
\def\itemize{%
  \ifnum \@itemdepth >\thr@@\@toodeep\else
    \advance\@itemdepth\@ne
    \edef\@itemitem{labelitem\romannumeral\the\@itemdepth}%
    \expandafter
    \list
      \csname\@itemitem\endcsname
      {\def\makelabel##1{\hss\llap{##1}}}%
  \fi}
\let\enditemize =\endlist


%%_________________________________________________________________

\def\@iedmakelabelleft#1{\makebox[\labelwidth][l]{\normalfont #1}}
\def\@iedmakelabelright#1{\makebox[\labelwidth][r]{\normalfont #1}}
\def\@iedmakelabelcenter#1{\makebox[\labelwidth][c]{\normalfont #1}}

%editorial main text definition 2005/7/20
\newenvironment{editorial}[2]{%
  \newlength{\lineskiplength}
  \setlength{\lineskiplength}{#1}
  \lineskiplength=1.143\lineskiplength% if font size is 10.5pt, baselineskip is 12pt (same article)
  \if@twocolumn%%default
    \fontsize{#1}{\lineskiplength}\selectfont
  \else%%single column case
    \newlength{\editorialtextwidth}
    \setlength{\editorialtextwidth}{#2}
    \newlength{\halfskip}
    \setlength{\halfskip}{\textwidth}
    \advance\halfskip by -\editorialtextwidth 
    \divide\halfskip by 2 
    \bgroup\setlength{\rightskip}{\halfskip} \setlength{\leftskip}{\halfskip}
    \vspace{-0.8em}\fontsize{#1}{\lineskiplength}\selectfont
  \fi}
  {\vspace{0.6em}\par
   \if@twocolumn\else\egroup\endquotation\fi
   \normalfont\normalsize}


%%abstract definition
\newenvironment{abstract}{%
  \if@twocolumn%%default
    \normalsize\bfseries\noindent
    \mathversion{bold}%数式$$内bold
  \else%%single column case
    \begin{center}\vspace{-0.8em}{\fontsize{10.5pt}{12pt}\selectfont\textbf{Abstract}\normalfont}\end{center}\bfseries 
   \fi}
  {\vspace{0.6em}\par
   \if@twocolumn\else\endquotation\fi
   \normalfont\normalsize}


\newenvironment{keywords}{
  % JACIII uses the term (in bold italics) "Index Terms" now. 
  \if@twocolumn
    \vspace{18pt}    % Useful!! 
    \noindent\textbf{Keywords: }$\!$%
  \else
    \begin{center}\small\bfseries Index Terms\end{center}\quotation\small
  \fi}
  {%
   \par\if@twocolumn\else\endquotation\fi
   \normalsize\normalfont}

\newenvironment{verse}
               {\let\\\@centercr
                \list{}{\itemsep      \z@
                        \itemindent   -1.5em
                        \listparindent\itemindent
                        \rightmargin  \leftmargin
                        \advance\leftmargin 1.5em}%
                \item\relax}
               {\endlist}
               
\newenvironment{quotation}
               {\list{}{\listparindent 1.5em
                        \itemindent    \listparindent
                        \rightmargin   \leftmargin
                        \parsep        0pt \@plus 1pt}
                \item\relax}
               {\endlist}
\newenvironment{quote}
               {\list{}{\rightmargin\leftmargin}%
                \item\relax}
               {\endlist}

\newenvironment{description}{%
  \list{}{%
    \labelwidth=\leftmargin
    \labelsep=1\jsZw
    \advance \labelwidth by -\labelsep
    \let \makelabel=\descriptionlabel}}{\endlist}
\newcommand*\descriptionlabel[1]{\normalfont\headfont #1\hfil}
  \newenvironment{titlepage}
    {%
      \if@twocolumn
        \@restonecoltrue\onecolumn
      \else
        \@restonecolfalse\newpage
      \fi
      \thispagestyle{empty}%
      \setcounter{page}\@ne
    }%
    {\if@restonecol\twocolumn \else \newpage \fi
     \if@twoside\else
        \setcounter{page}\@ne
     \fi
    }

\newcommand\appendix[1][Appendix]{\par
  \setcounter{section}{0}%
  \setcounter{subsection}{0}%
  \setcounter{subsubsection}{0}
  \setcounter{paragraph}{0}
  \gdef\thesection{Appendix \@Alph\c@section}
  \gdef\thesubsection{\@Alph\c@section.\@arabic\c@subsection}
  \normalsize
}

\setlength\arraycolsep    {5pt}
\setlength\tabcolsep      {6pt}
\setlength\arrayrulewidth {.4pt}
\setlength\doublerulesep  {2pt}
\setlength\tabbingsep{\labelsep}


\skip\footins 10pt plus 4pt minus 2pt
\footnotesep 3pt%separation length between footnotes
\footskip 32pt
\skip\@mpfootins = \skip\footins
\setlength\fboxsep{3pt}
\setlength\fboxrule{.4pt}


%%%%% Dotted equation number environment definition 
\newcommand\EqnDots{\leaders\hbox{\kern4\p@ .\kern4\p@}\hfill}
\@ifundefined{mathindent}{\newdimen\mathindent \mathindent\leftmargini}{}
\renewcommand{\[}{\relax \ifmmode\@badmath \else
 \begin{trivlist}%
  \@beginparpenalty\predisplaypenalty \@endparpenalty\postdisplaypenalty
  \item[]\leavevmode \hbox to\linewidth\bgroup $\m@th\displaystyle %$
  \hskip\mathindent\bgroup
 \fi}
\renewcommand{\]}{\relax\ifmmode \egroup $\hfil% $
    \egroup \end{trivlist}%
  \else \@badmath \fi}
\renewenvironment{equation}%
 {\@beginparpenalty\predisplaypenalty \@endparpenalty\postdisplaypenalty
     \refstepcounter{equation}\trivlist \item[]\leavevmode
       \hbox to\linewidth\bgroup $\m@th% $
         \displaystyle \hskip\mathindent}%
 {$\EqnDots % $   Replace `\hfil' with dotted leaders `\EqnDots'.
     \displaywidth\linewidth\hbox{\@eqnnum}\egroup \endtrivlist}
\renewenvironment{eqnarray}{%
  \stepcounter{equation}%
  \def\@currentlabel{\p@equation\theequation}%
  \global\@eqnswtrue \m@th \global\@eqcnt\z@  \tabskip\mathindent
  \let\\\@eqncr \setlength\abovedisplayskip\topsep
  \ifvmode \addtolength\abovedisplayskip\partopsep \fi
  \addtolength\abovedisplayskip\parskip
  \setlength\belowdisplayskip\abovedisplayskip
  \setlength\belowdisplayshortskip\abovedisplayskip
  \setlength\abovedisplayshortskip\abovedisplayskip
  $$\everycr{}\halign to\linewidth% $$
  \bgroup
    \hskip\@centering
    $\displaystyle\tabskip\z@skip{##}$\@eqnsel&%
    \global\@eqcnt\@ne \hfil${\hskip\tw@\eqarcolsep##\hskip\tw@\eqarcolsep}$\hfil&%
  %    \global\@eqcnt\@ne \hfil${\DEQ@acs##\DEQ@acs}$\hfil&%
    \global\@eqcnt\tw@ $\displaystyle{##}$\hskip\@centering\cr%
}% end of "\begin" part
{\@@eqncr
  \noalign{% vertical skip up to overlay phantom line
    \penalty\@M \vskip-\prevdepth
    \edef\@tempa{\omit\span\omit\span\omit   % span three columns
      \vrule\@depth\the\prevdepth \@width\z@ % strut of proper depth
      \kern-\mathindent \kern\linewidth}%    % full line width
    \nointerlineskip \expandafter % use saved |\@tempa| outside group
  }\@tempa\cr
  \egroup
  \global\advance\c@equation\m@ne$$% $$
  \global\@ignoretrue
}
\def\@@eqncr{\let\reserved@a\@empty
   \ifcase\@eqcnt \def\reserved@a{& &}\or \def\reserved@a{&}\fi
   \reserved@a
   \if@eqnsw \egroup $\EqnDots \@eqnnum $\bgroup \stepcounter{equation}%
   \fi \global\@eqnswtrue\global\@eqcnt\z@\cr}
\def\DEQ@acs{\hskip\tw@\arraycolsep}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcounter{figure}
\renewcommand \thefigure {\@arabic\c@figure}
\def\fps@figure{tbp}
\def\ftype@figure{1}
\def\ext@figure{lof}

\def\fnum@figure{\textbf{Fig.~\thefigure.~}}

\newenvironment{figure}
               {\@float{figure}}
               {\end@float}
\newenvironment{figure*}
               {\@dblfloat{figure}}
               {\end@dblfloat}

\newcounter{table}
\renewcommand\thetable{\@arabic\c@table}
\def\fps@table{tbp}
\def\ftype@table{2}
\def\ext@table{lot}

\def\fnum@table{\textbf{Table~\thetable.~}}

\newenvironment{table}
               {\@float{table}}
               {\end@float}
\newenvironment{table*}
               {\@dblfloat{table}}
               {\end@dblfloat}

\newlength\abovecaptionskip
\newlength\belowcaptionskip
\setlength\abovecaptionskip{10\p@}
\setlength\belowcaptionskip{10\p@}


%% caption configuration
\newlength\figcaptionindent
\setlength\figcaptionindent{10\p@}

%\makeatletter 
\long\def\@makecaption#1#2{%
  \vskip\abovecaptionskip
  \sbox\@tempboxa{\small #1 #2}%
  \ifdim \wd\@tempboxa>\hsize %-2\figcaptionindent%   
    \sbox\@tempboxa{\small #1 #2}%
    \@tempdima\hsize \advance\@tempdima-2\figcaptionindent
    \hskip\figcaptionindent \parbox[t]{\@tempdima}{\small #1 #2}\relax\par
 \else
    \global \@minipagefalse
    \hbox to\hsize{\hfil\box\@tempboxa\hfil}
  \fi
  \vskip\belowcaptionskip}
%\makeatother

% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

\newcommand\appendices{\par
  \setcounter{section}{-1} % we want \refstepcounter to use section 0
  \setcounter{subsection}{0}
  \setcounter{subsubsection}{0}
  \setcounter{paragraph}{0}
  \ifuseRomanappendices
    \newcommand\thesection{\Roman{section}}
    \newcommand\thesectiondis{\Roman{section}}
  \else
    \newcommand\thesection{\Alph{section}}
    \newcommand\thesectiondis{\Alph{section}}
  \fi
  \refstepcounter{section} % update the \ref counter
  \setcounter{section}{0} % NEXT \section will be the FIRST appendix
  % redefine \section command for appendices
  % leave \section* as is
  \newcommand\section{
    \@ifstar{\@ppendixsavesection*}{% process the *-form
      \refstepcounter{section} % or is a new section so,
      \@processthesectionargument
    }
  }% process the argument of the normal form
}


\def\CMPARstart#1#2{\begingroup\def\par{\endgraf\endgroup\lineskiplimit=0pt}
    \setbox2=\hbox{\uppercase{#2} }\newdimen\tmpht \tmpht \ht2
    \advance\tmpht by \baselineskip\font\hhuge=cmr10 at \tmpht
    \setbox1=\hbox{{\hhuge #1}}
    \count7=\tmpht \count8=\ht1\divide\count8 by 1000 \divide\count7 by\count8
    \tmpht=.001\tmpht\multiply\tmpht by \count7\font\hhuge=cmbx10 at \tmpht
    \setbox1=\hbox{{\hhuge #1}} \noindent \hangindent1.05\wd1
    \hangafter=-2 {\hskip-\hangindent \lower1\ht1\hbox{\raise1.0\ht2\copy1}%
    \kern-0\wd1}\copy2\lineskiplimit=-1000pt}


\def\PARstart#1#2{\begingroup\def\par{\endgraf\endgroup\lineskiplimit=0pt}
    \setbox2=\hbox{\uppercase{#2}}\newdimen\tmpht \tmpht \ht2
    \advance\tmpht by 1.1\baselineskip\font\hhuge=ptmr at \tmpht
    \setbox1=\hbox{{\hhuge #1}}
    \count7=\tmpht \count8=\ht1\divide\count8 by 1000 \divide\count7 by\count8
    \tmpht=.001\tmpht\multiply\tmpht by \count7\font\hhuge=ptmb at \tmpht
    \setbox1=\hbox{{\hhuge #1}} \noindent \hangindent1.05\wd1
    \hangafter=-2 {\hskip-\hangindent \lower1\ht1\hbox{\raise1.0\ht2\copy1}%
    \kern-0\wd1}\copy2\lineskiplimit=-1000pt}

\if@technote\def\PARstart#1#2{#1#2}\def\CMPARstart#1#2{#1#2}\fi     % if technical note, disable it
\if@draftclsmode\def\PARstart#1#2{#1#2}\def\CMPARstart#1#2{#1#2}\fi % if draft, disable it

%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&


\newenvironment{biography}[2][]{%
  \addcontentsline{toc}{section}{Biography}
  \footnotesize\unitlength 1in\bigskip\parskip=0pt\par%
  \rule{0pt}{1.54in}\vspace{-1.54in}\par%   guarantees correct page breaking
  \noindent
  % the default box for where the photo goes
  \def\@tempbiographybox{
    \hbox{
      \framebox(1,1.25){
         \parbox[][\height][c]{0.9in}{
           \centering PLACE\\ PHOTO\\ HERE
         }
       } 
     }
  }%
  \@ifmtarg{#1}{\relax}{%
    %   % The user supplied the optional argument
    %   % override the default box with what they want
    \def\@tempbiographybox{
      \hbox{%
        \begin{minipage}[b][1.25in][c]{1in}%
        \centering
        #1%
        \end{minipage}
      }
    }%
  }% end if optional argument supplied
  \setbox0\@tempbiographybox%
  \ht0=1.45in\count10=\ht0\divide\count10 by\baselineskip%  calculates lines
  \global\hangindent1.14in\global\hangafter-\count10%
  \hskip-1.12in\setbox0\hbox to 1.12in {\raise-1.2in\box0\hss}%
  \dp0=0in\ht0=0in\box0\noindent{\bfseries#2}\rmfamily
} 
{
  \par
  \ifnum \prevgraf <\count10 % detect when the biography text is shorter than the photo
    \count11=\count10
    \advance\count11 by -\prevgraf % calculate how many lines we need to pad
    \dimen10=\baselineskip % calculate the length of the padding
    \multiply\dimen10 by \count11
    \noindent\rule{0pt}{\dimen10} % insert an invisible support strut
  \fi
  \par\normalfont
}


\DeclareOldFontCommand{\rm}{\normalfont\rmfamily}{\mathrm}
\DeclareOldFontCommand{\sf}{\normalfont\sffamily}{\mathsf}
\DeclareOldFontCommand{\tt}{\normalfont\ttfamily}{\mathtt}
\DeclareOldFontCommand{\bf}{\normalfont\bfseries}{\mathbf}
\DeclareOldFontCommand{\it}{\normalfont\itshape}{\mathit}
\DeclareOldFontCommand{\sl}{\normalfont\slshape}{\@nomath\sl}
\DeclareOldFontCommand{\sc}{\normalfont\scshape}{\@nomath\sc}
\DeclareRobustCommand*\cal{\@fontswitch\relax\mathcal}
\DeclareRobustCommand*\mit{\@fontswitch\relax\mathnormal}

\newcommand\@pnumwidth{1.55em}
\newcommand\@tocrmarg{2.55em}
\newcommand\@dotsep{4.5}
\setcounter{tocdepth}{3}

\def\@specialpapernotice{\relax}


\def\specialpapernotice#1{\def\@specialpapernotice{%
\\*[1.5ex]\textit{#1}\vspace*{-2ex}}}

\newcommand\tableofcontents{\ssection*{Contents}\@starttoc{toc}}

\newcommand*\l@section[2]{%
  \addpenalty\@secpenalty
  \addvspace{1.0em \@plus 1pt}%
  \setlength\@tempdima{2.75em}%
  \begingroup
    \parindent \z@ \rightskip \@pnumwidth
    \parfillskip -\@pnumwidth
    {\bfseries\leavevmode #1}
    \hfil\hbox to\@pnumwidth{\hss #2} \par 
  \endgroup}

\newcommand*\l@subsection{\@dottedtocline{2}{2.75em}{3.75em}}
\newcommand*\l@subsubsection{\@dottedtocline{3}{6.5em}{4.5em}}
\newcommand*\l@paragraph{\@dottedtocline{4}{6.5em}{5.5em}}
\newcommand*\l@subparagraph{\@dottedtocline{5}{6.5em}{6.5em}}

\newdimen\tmpitemindent
\newcommand\QED{\mbox{\rule[0pt]{1.5ex}{1.5ex}}}

\newenvironment{proof}{ 
  \noindent\hspace{2em}{\itshape Proof: }
}
   {\hspace*{\fill}~\QED\par\endtrivlist\unskip}
  
\def\@begintheorem#1#2{\tmpitemindent\itemindent\topsep 0pt\rmfamily\trivlist
    \item[\hskip \labelsep{\indent\itshape #1\ #2:}]\itemindent\tmpitemindent}
\def\@opargbegintheorem#1#2#3{\tmpitemindent\itemindent\topsep 0pt\rmfamily \trivlist

\item[\hskip\labelsep{\indent\itshape #1\ #2\rmfamily---#3:}]\itemindent\tmpitemindent}
\def\@endtheorem{\endtrivlist\unskip}

\newcommand\listoffigures{%
  \ssection*{\listfigurename
    \@mkboth{\MakeUppercase\listfigurename}%
            {\MakeUppercase\listfigurename}}%
  \@starttoc{lof}%
}

\newcommand*\l@figure{\@dottedtocline{1}{0em}{2.75em}}

\newcommand\listoftables{\ssection*{List of Tables}\@starttoc{lot}}
\let\l@table\l@figure

\newcommand\refname{References:}
\newdimen\bibindent
\setlength\bibindent{1.5em}
\newenvironment{thebibliography}[1]{
  \ssection*{\small \refname} 
  \addcontentsline{toc}{section}{References}
  \vspace*{-10pt}
  \renewcommand\baselinestretch{1}
  \footnotesize
  \setlength{\itemindent}{12pt}
  \setlength{\labelwidth}{3em}
  \setlength{\labelsep}{5pt}
  \list{[\arabic{enumi}]}{
    \advance\leftmargin\labelsep 
    \itemsep 0pt plus .5pt
    \usecounter{enumi}}
  \def\newblock{\hskip .11em plus .33em minus .07em}
  \if@technote 
    \sloppy\clubpenalty4000\widowpenalty4000\interlinepenalty100%
    \else 
    \sloppy\clubpenalty4000\widowpenalty4000\interlinepenalty500
  \fi%
  \sfcode`\.=1000\relax}{\endlist}
\newcommand\newblock{\hskip .11em\@plus.33em\@minus.07em}
\let\@openbib@code\@empty

%Supporting Online Materials
\newenvironment{onlinematerials}[1]{
  \ssection*{\small Supporting Online Materials:} 
  \addcontentsline{toc}{section}{References}
  \vspace*{-10pt}
  \renewcommand\baselinestretch{0.85}%
  \footnotesize
  \setlength{\itemindent}{12pt}
  \setlength{\labelwidth}{3em}
  \setlength{\labelsep}{5pt}
  \list{[\alph{enumi}]}{
    \advance\leftmargin\labelsep 
    \itemsep 0pt plus .5pt
    \usecounter{enumi}}
  \if@technote 
    \sloppy\clubpenalty4000\widowpenalty4000\interlinepenalty100%
    \else 
    \sloppy\clubpenalty4000\widowpenalty4000\interlinepenalty500
  \fi%
  \sfcode`\.=1000\relax}{\endlist}
\let\@openbib@code\@empty


\newenvironment{theindex}
      {\if@twocolumn
        \@restonecolfalse
      \else
        \@restonecoltrue
      \fi
      \columnseprule \z@
      \columnsep 35\p@
      \twocolumn[\ssection*{\indexname}]%
      \@mkboth{\MakeUppercase\indexname}%
              {\MakeUppercase\indexname}%
      \thispagestyle{plain}\parindent\z@
      \parskip\z@ \@plus .3\p@\relax
      \let\item\@idxitem}
      {\if@restonecol\onecolumn\else\clearpage\fi}
\newcommand\@idxitem{\par\hangindent 40\p@}
\newcommand\subitem{\@idxitem \hspace*{20\p@}}
\newcommand\subsubitem{\@idxitem \hspace*{30\p@}}
\newcommand\indexspace{\par \vskip 10\p@ \@plus5\p@ \@minus3\p@\relax}

\renewcommand\footnoterule{\vspace*{5pt}\noindent\rule{25.0mm}{0.4pt} \vspace*{3pt}}

\long\def\@makefntext#1{\parindent 1.5em\noindent\@hangfrom{\hbox to 1.2em{\hss$\@thefnmark$.\hspace*{.5em}}}#1}

\newcommand\listfigurename{List of Figures}
\newcommand\indexname{Index}
\newcommand\figurename{Figure}

\def\today{\ifcase\month\or
  January\or February\or March\or April\or May\or June\or
  July\or August\or September\or October\or November\or December\fi
  \space\number\day, \number\year}

\setlength\columnseprule{0\p@}

\pagestyle{plain}
\pagenumbering{arabic}

\if@twoside
\else
  \raggedbottom
\fi
\if@twocolumn
  \twocolumn
  \sloppy
  \flushbottom
\else
  \onecolumn
\fi

%%%%%%%%%%%%%%%%% profile configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%

\newif \if@proifname \@proifnamefalse
\newif \if@proiforcid \@proiforcidfalse
\newif \if@proifaffiliation \@proifaffiliationfalse
\newif \if@proifaddress \@proifaddressfalse
\newif \if@proifhistory \@proifhistoryfalse
\newif \if@proifworks \@proifworksfalse
\newif \if@proifmembership \@proifmembershipfalse
\newif \if@proifphoto \@proifphotofalse

\newcommand{\Name}[1]{\def\pro@name{#1} \@proifnametrue}
\newcommand{\Orcid}[1]{\def\pro@orcid{#1} \@proiforcidtrue}
\newcommand{\Affiliation}[1]{\def\pro@affiliation{#1} \@proifaffiliationtrue}
\newcommand{\Address}[1]{\def\pro@address{#1} \@proifaddresstrue}
\newcommand{\History}[1]{\def\pro@history{#1} \@proifhistorytrue}
\newcommand{\Works}[1]{\def\pro@works{#1} \@proifworkstrue}
\newcommand{\Membership}[1]{\def\pro@membership{#1} \@proifmembershiptrue}
\newcommand{\Photo}[1]{\def\pro@photo{#1} \@proifphototrue}

%%%%profile environment
\newenvironment{profile}{}{%%%Define Profile output
  \if@doubleskip\renewcommand\baselinestretch{1}\fi%reset baseline skip
	\if@profile
		\begin{flushleft}
      \vbox{%
        \if@proifphoto
          \noindent\rule{240pt}{1pt}\\
            \vspace*{-3mm}
            \hbox{%
              \noindent%
              \begin{minipage}[t]{70.86pt}%
                \setlength{\unitlength}{1pt}%
                \vspace*{10pt}
                \makebox(70.86,93.54)[c]{
                  \if@proifphoto
                    {\includegraphics[width=70.86pt,height=93.54pt]{\pro@photo}}
                  \else Place Photo Here
                  \fi
                }
              \end{minipage}\hspace*{14.16pt}%

              \begin{minipage}[t]{154.98pt}%240pt-(70.86+14.16)
                \vspace*{1pc}%
                \vbox{\hsize=154.98pt \baselineskip 9.2pt
                  \if@proifname
                        {\fontsize{9pt}{10.35pt}\selectfont\bfseries%
                    Name: \\ \normalfont}%
                        {\fontsize{8pt}{9.2pt}\selectfont%
                    \pro@name \normalfont}
                  \fi
                  \vspace*{1pc}%
                  \\
                  \if@proiforcid%
                        {\fontsize{9pt}{10.35pt}\selectfont\bfseries%
                    ORCID:\\ \normalfont}%
                        {\fontsize{8pt}{9.2pt}\selectfont%https://orcid.org/
                        \pro@orcid \\ \normalfont}%
                  \fi
                  \\
                  \if@proifaffiliation%
                        {\fontsize{9pt}{10.35pt}\selectfont\bfseries%
                    Affiliation:\\ \normalfont}%
                        {\fontsize{8pt}{9.2pt}\selectfont%
                    \pro@affiliation \\ \normalfont}%
                  \fi
                }
              \end{minipage}%
            }% end of hbox
          \vspace{7pt}%
        \else
          \noindent\rule{240pt}{1pt}\\
          \if@proifname
            \vspace{11pt}%
                {\fontsize{9pt}{10.35pt}\selectfont\bfseries%
            Name: \\ \normalfont}%
                {\fontsize{8pt}{9.2pt}\selectfont%
            \pro@name \\ \normalfont}
          \fi
          \vspace{11pt}%
          \if@proiforcid%
                {\fontsize{9pt}{10.35pt}\selectfont\bfseries%
              ORCID: \\ \normalfont}%
                {\fontsize{8pt}{9.2pt}\selectfont%https://orcid.org/
              \pro@orcid \\ \normalfont}%
          \fi
          \if@proifaffiliation%
                {\fontsize{9pt}{10.35pt}\selectfont\bfseries%
            Affiliation:\\ \normalfont}%
                {\fontsize{8pt}{9.2pt}\selectfont%
            \pro@affiliation \\ \normalfont}%
          \fi
        \fi%

          \vbox{\hsize=240pt \baselineskip 9.2pt% 
            \vspace{1.35pt}%
            \if@proifaddress%
              {\fontsize{9.0pt}{10.35pt}\selectfont\bfseries%
                \noindent Address:\\ \normalfont}%
              {\fontsize{8.0pt}{9.2pt}\selectfont%
                \pro@address \\ \normalfont}%
            \fi%
            \if@proifhistory%
              {\fontsize{9.0pt}{10.35pt}\selectfont\bfseries%
                \pro@career \\ \normalfont}%
              {\fontsize{8.0pt}{9.2pt}\selectfont%
                \pro@history \\ \normalfont}%
            \fi%
            \if@proifworks%
              {\fontsize{9.0pt}{10.35pt}\selectfont\bfseries%
                \pro@publications \\ \normalfont}%
              {\fontsize{8.0pt}{9.2pt}\selectfont%
                \pro@works \\ \normalfont}%
            \fi%
            \if@proifmembership%
              {\fontsize{9.0pt}{10.35pt}\selectfont\bfseries%
                \pro@societies \\ \normalfont}%
              {\fontsize{8.0pt}{9.2pt}\selectfont%
                \pro@membership  \normalfont}%
            \fi%
          }%end of the lower vbox  
          \vspace{-3pt}%
          \noindent\rule{240pt}{1pt}
      }% end of vbox
		\end{flushleft}%
    \vspace{2pt}%
	\fi%%end of if@profile
}% End of Profile


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	       
%%Output for xml
\def\lastpage@putlabel{\addtocounter{page}{-1}%
  \immediate\write\@auxout{% putput to aux file
   \string\newlabel{Kind}{\@articlekindOut}^^J%
   \string\newlabel{LastPage}{\thepage}^^J%
   \string\newlabel{Language}{\@languageOut}^^J%
 }%
  \addtocounter{page}{1}}
\AtEndDocument{%
  \message{AED: lastpage setting LastPage}%
   \clearpage\lastpage@putlabel
}%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

\endinput

%% End of file `fujipressarticle.cls'.
