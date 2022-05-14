%%%-------------------------------------------------------------------
%%% @author dhuynh
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. May 2022 9:45 PM
%%%-------------------------------------------------------------------
-module(post_server).
-author("dhuynh").

-behaviour(gen_server).
%% API
-export([start_link/0, insert/2, get_post_by_id/1,
         get_posts_by_author/1, delete_post/1,add_comment/3,
         get_all_posts_from_date/4, get_all_posts_from_month/3,
         get_comments/1]).


%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
          code_change/3]).

start_link() ->
  io:format("~nPost server start~n"),
  gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

insert(Author, Content) ->
  gen_server:call({global, ?MODULE}, {insert, Author, Content}).

get_post_by_id(Id) ->
  gen_server:call({global, ?MODULE}, {get_post_by_id, Id}).

get_posts_by_author(Author) ->
  gen_server:call({global, ?MODULE}, {get_posts_by_author, Author}).

delete_post(Id) ->
  gen_server:call({global, ?MODULE}, {delete_post, Id}).

add_comment(Id, Username, Comment) ->
  gen_server:call({global, ?MODULE}, {add_comment, Id, Username, Comment}).

get_all_posts_from_date(Year, Month, Date, Author) ->
  gen_server:call({global, ?MODULE}, {get_all_posts_from_date, Year, Month, Date, Author}).

get_all_posts_from_month(Year, Month, Author) ->
  gen_server:call({global, ?MODULE}, {get_all_posts_from_month, Year, Month, Author}).

get_comments(Id) ->
  gen_server:call({global, ?MODULE}, {get_comments, Id}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INTERNAL FUNCTIONS %%%%%%%%%%%%%%%%%
init([]) ->
    io:format("~p (~p) starting.... ~n", [{local, ?MODULE}, self()]),
    {ok, []}.


handle_call({insert, Author, Content}, _From, State) ->
    postdb:insert(Author, Content),
    {reply, ok, State};

handle_call({get_post_by_id, Id}, _From, State) ->
    Posts = postdb:get_post_by_id(Id),
    {reply, Posts, State};

handle_call({get_posts_by_author, Author}, _From, State) ->
    Posts = postdb:get_posts_by_author(Author),
    {reply, Posts, State};

handle_call({add_comment, Id, Username, Comment}, _From, State) ->
    postdb:add_comment(Id, Username, Comment),
    {reply, ok, State};

handle_call({get_all_posts_from_date, Year, Month, Date, Author}, _From, State) ->
    Posts = postdb:get_all_posts_from_date(Year, Month, Date, Author),
    {reply, Posts, State};

handle_call({get_all_posts_from_month, Year, Month, Author}, _From, State) ->
    Posts = postdb:get_all_posts_from_month(Year, Month, Author),
    {reply, Posts, State};

handle_call({get_comments, Id}, _From, State) ->
    Comments = postdb:get_comments(Id),
    {reply, Comments, State};

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
