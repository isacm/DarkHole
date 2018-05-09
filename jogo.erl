-module(jogo).
-export([server/1]).

% Inicia o servidro , Port - nº de porta a abrir
server(Port) ->
	Pid1 = spawn(fun() -> room([]) end),
	register(listaEspera,Pid1),
	Pid3 = spawn(fun() -> login(#{}) end),
	register(gestorLogin,Pid3),
	{ok,Socket} = gen_tcp:listen(Port, [{packet, line}, {reuseaddr, true}]),
	acceptor(Socket).

% Fica à espera que alguem entre
acceptor(Socket) ->
	{ok,Sock} = gen_tcp:accept(Socket),
	spawn(fun() -> acceptor(Socket) end),
	user(Sock).

% Verica os logins e registos
login(Uti) ->
	receive
		{From,registar,User,Pass} ->
			case maps:find(User,Uti) of
				error ->
					From ! {ok,registo},
					login(maps:put(User,Pass,Uti));
				{ok,_} ->
					From ! {erro,registo},
					login(Uti)
			end;
		{From,login,User,Pass} ->
			case maps:find(User,Uti) of
				error ->
					From ! {erro,login},
					login(Uti);
				{ok,Value} ->
					case Pass == Value of
						true ->
							From ! {ok,login},
							login(Uti);
						false ->
							From ! {erro,login},
							login(Uti)
					end
			end
	end.

% Estado apos fazer login
userlogin(Sock) ->
	receive
		{start,Jogo} -> 
			gen_tcp:send(Sock,"comecar\n"),
			userjogo(Sock,Jogo);
		{tcp_closed, _} ->
			listaEspera ! {sair, self()};
		{tcp_error, _, _} -> 
			listaEspera ! {sair, self()}
	end.

% Estado antes do login
user(Sock) ->
	receive
		{ok,registo} -> 
			gen_tcp:send(Sock,"registook\n"),
			user(Sock);
		{erro,registo} -> 
			gen_tcp:send(Sock,"registoinvalido\n"),
			user(Sock);
		{ok,login} ->
			gen_tcp:send(Sock,"loginok\n"),
			listaEspera ! {entrar,self()},
			userlogin(Sock);
		{erro,login} ->
			gen_tcp:send(Sock,"logininvalido\n"),
			user(Sock);
		{tcp_closed, _} ->
			listaEspera ! {sair, self()};
		{tcp,Sock,Data} ->
			Data1 = removebarran(Data),
			case Data1 of
				[] -> 
					user(Sock);
				_  -> 
					parser2(string:tokens(Data1," "),self()),
					user(Sock)
			end;
		{tcp_error, _, _} -> 
			listaEspera ! {sair, self()}
	end.

% Estado apos começar o jogo
userjogo(Sock,Jogo) ->
	receive
		{tcp,Sock,Data} ->
			Data1 = removebarran(Data),
			case Data1 of
				[] -> 
					userjogo(Sock, Jogo);
				_ -> 
					parser(string:tokens(Data1," "),Jogo),
					userjogo(Sock, Jogo)
			end;
		{enviar, Data} ->
			gen_tcp:send(Sock,[Data]),
			userjogo(Sock, Jogo);
		{tcp_closed, _} ->
			Jogo ! {sair, self()};
		{tcp_error, _, _} -> 
			Jogo ! {sair, self()}
	end.

% Parser para logins
parser2(Tokens,From) ->
	case lists:nth(1,Tokens) of
		"registar" ->
			gestorLogin ! {From,registar,lists:nth(2,Tokens),lists:nth(3,Tokens)};
		"login" ->
			gestorLogin ! {From,login,lists:nth(2,Tokens),lists:nth(3,Tokens)}
	end.

% Faz o parsing do input do socket e envia as mensagens ao jogo
parser(Tokens,Jogo) ->
	case lists:nth(1,Tokens) of
		"movimento" ->
			case lists:nth(2,Tokens) of
				"F" -> Jogo ! {self(),movimento,frente};
				"E" -> Jogo ! {self(),movimento,esquerda};
				"D" -> Jogo ! {self(),movimento,direita}
			end;
		"frame" -> Jogo ! {self(),frame};
		_ -> true
	end.

% Faz a gestao do jogo
jogo(J1,J2,MJ1,MJ2,LP) ->
	receive
		{J1,movimento,frente} ->
			case impactonavebh(maps:get(pos,MJ1)) of
				false ->
					jogo(J1,J2,movimentofrente(accmovimentofrente(MJ1)),MJ2,LP);
				true ->
					jogo(J1,J2,MJ1,MJ2,LP)
			end;
		{J2,movimento,frente} ->
			case impactonavebh(maps:get(pos,MJ2)) of
				false ->
					jogo(J1,J2,MJ1,movimentofrente(accmovimentofrente(MJ2)),LP);
				true ->
					jogo(J1,J2,MJ1,MJ2,LP)
			end;
		{J1,movimento,esquerda} ->
			jogo(J1,J2,rotacaoesquerda(MJ1),MJ2,LP);
		{J2,movimento,esquerda} ->
			jogo(J1,J2,MJ1,rotacaoesquerda(MJ2),LP);
		{J1,movimento,direita} ->
			jogo(J1,J2,rotacaodireita(MJ1),MJ2,LP);
		{J2,movimento,direita} ->
			jogo(J1,J2,MJ1,rotacaodireita(MJ2),LP);
		{sair,From} -> 
			io:format("disconnected ~p ~n",[From]);
		{J1,frame} ->
			PA = mensagemplanetas(atualizaplanetas(LP)),
			J1 ! {enviar,PA},
			J2 ! {enviar,PA},
			case impactonavenave(maps:get(pos,MJ1),maps:get(pos,MJ2)) of
				true ->
					MJ1A = atualizaposimpactonn(atualizaspeedimpactonn(MJ1,MJ2)),
					MJ2A = atualizaposimpactonn(atualizaspeedimpactonn(MJ2,MJ1)),
					case impactonavebh(maps:get(pos,MJ1A)) of
						false ->
							MJ1AB = atualizaposgravbh(atualizaspeedgravbh(MJ1A)),
							case impactonavebh(maps:get(pos,MJ2A)) of
								false ->
									MJ2AB = atualizaposgravbh(atualizaspeedgravbh(MJ2A)),
									J1 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ1AB,LP))},
									J1 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ2AB,LP))},
									J2 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ2AB,LP))},
									J2 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ1AB,LP))},
									jogo(J1,J2,resetdirmag(resetaccel(atualizaposnaveplaneta(MJ1AB,LP))),resetdirmag(resetaccel(atualizaposnaveplaneta(MJ2AB,LP))),atualizaplanetas(LP));
								true ->
									J1 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ1AB,LP))},
									J1 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ2A,LP))},
									J2 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ2A,LP))},
									J2 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ1AB,LP))},
									jogo(J1,J2,resetdirmag(resetaccel(atualizaposnaveplaneta(MJ1AB,LP))),resetdirmag(resetaccel(MJ2A)),atualizaplanetas(LP))
							end;
						true ->
							case impactonavebh(maps:get(pos,MJ2A)) of
								false ->
									MJ2AB = atualizaposgravbh(atualizaspeedgravbh(MJ2A)),
									J1 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ1A,LP))},
									J1 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ2AB,LP))},
									J2 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ2AB,LP))},
									J2 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ1A,LP))},
									jogo(J1,J2,resetdirmag(resetaccel(MJ1A)),resetdirmag(resetaccel(atualizaposnaveplaneta(MJ2AB,LP))),atualizaplanetas(LP));
								true ->
									J1 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ1A,LP))},
									J1 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ2A,LP))},
									J2 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ2A,LP))},
									J2 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ1A,LP))},
									jogo(J1,J2,resetdirmag(resetaccel(MJ1A)),resetdirmag(resetaccel(MJ2A)),atualizaplanetas(LP))
							end
					end;
				false -> 
					case impactonavebh(maps:get(pos,MJ1)) of
						false ->
							MJ1AB = atualizaposgravbh(atualizaspeedgravbh(MJ1)),
							case impactonavebh(maps:get(pos,MJ2)) of
								false ->
									MJ2AB = atualizaposgravbh(atualizaspeedgravbh(MJ2)),
									J1 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ1AB,LP))},
									J1 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ2AB,LP))},
									J2 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ2AB,LP))},
									J2 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ1AB,LP))},
									jogo(J1,J2,resetdirmag(resetaccel(atualizaposnaveplaneta(MJ1AB,LP))),resetdirmag(resetaccel(atualizaposnaveplaneta(MJ2AB,LP))),atualizaplanetas(LP));
								true ->
									J1 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ1AB,LP))},
									J1 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ2,LP))},
									J2 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ2,LP))},
									J2 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ1AB,LP))},
									jogo(J1,J2,resetdirmag(resetaccel(atualizaposnaveplaneta(MJ1AB,LP))),resetdirmag(resetaccel(MJ2)),atualizaplanetas(LP))
							end;
						true ->
							case impactonavebh(maps:get(pos,MJ2)) of
								false ->
									MJ2AB = atualizaposgravbh(atualizaspeedgravbh(MJ2)),
									J1 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ1,LP))},
									J1 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ2AB,LP))},
									J2 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ2AB,LP))},
									J2 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ1,LP))},
									jogo(J1,J2,resetdirmag(resetaccel(MJ1)),resetdirmag(resetaccel(atualizaposnaveplaneta(MJ2AB,LP))),atualizaplanetas(LP));
								true ->
									J1 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ1,LP))},
									J1 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ2,LP))},
									J2 ! {enviar,mensagemjogador(atualizaposnaveplaneta(MJ2,LP))},
									J2 ! {enviar,mensagemadversario(atualizaposnaveplaneta(MJ1,LP))},
									jogo(J1,J2,resetdirmag(resetaccel(MJ1)),resetdirmag(resetaccel(MJ2)),atualizaplanetas(LP))
							end
					end
			end;
			_ -> 
				jogo(J1,J2,MJ1,MJ2,LP)
	end.

% Verifica se houve impacto nave planeta ou nao e aplica os calculos conforme o necessario
atualizaposnaveplaneta(MJ,[P]) ->
	case impactonaveplaneta(maps:get(pos,MJ),maps:get(pos,P),maps:get(raio,P)) of
		true ->
			atualizaposimpactoplan(atualizaspeedimpactoplan(MJ,P));
		false ->
			atualizaposgravplaneta((atualizaspeedgravplaneta(MJ,P)))
	end;

atualizaposnaveplaneta(MJ,LP) ->
	[H|T] = LP,
	case impactonaveplaneta(maps:get(pos,MJ),maps:get(pos,H),maps:get(raio,H)) of
		true ->
			atualizaposnaveplaneta(atualizaposimpactoplan(atualizaspeedimpactoplan(MJ,H)),T);
		false ->
			atualizaposnaveplaneta(atualizaposgravplaneta(atualizaspeedgravplaneta(MJ,H)),T)
	end.


% Mensagem para enviar ao cliente com a sua pos
mensagemjogador(MJ) ->
	case maps:get(pos,MJ) of
		{X,Y} ->
			case maps:get(dir,MJ) of
				Dir ->
					case maps:get(fuel,MJ) of
						Fuel ->
							case maps:get(dirmagright,MJ) of
								{RX,RY} ->
									case maps:get(dirmagleft,MJ) of
										{LX,LY} ->
											case maps:get(accel,MJ) of
												{AX,AY} ->
													"jogador "++float_to_list(X)++" "++float_to_list(Y)++" "++float_to_list(AX)++" "++float_to_list(AY)++" "++float_to_list(Dir)++" "++float_to_list(Fuel)++" "++float_to_list(RX)++" "++float_to_list(RY)++" "++float_to_list(LX)++" "++float_to_list(LY)++" "++mensagemvivo(MJ)
											end
									end
							end
					end
			end
	end.

% Mensagem para enviar ao cliente com a pos do adv
mensagemadversario(MJ) ->
	case maps:get(pos,MJ) of
		{X,Y} ->
			case maps:get(dir,MJ) of
				Dir ->
					case maps:get(fuel,MJ) of
						Fuel ->
							case maps:get(dirmagright,MJ) of
							{RX,RY} ->
								case maps:get(dirmagleft,MJ) of
									{LX,LY} ->
										case maps:get(accel,MJ) of
											{AX,AY} ->
												"adversario "++float_to_list(X)++" "++float_to_list(Y)++" "++float_to_list(AX)++" "++float_to_list(AY)++" "++float_to_list(Dir)++" "++float_to_list(Fuel)++" "++float_to_list(RX)++" "++float_to_list(RY)++" "++float_to_list(LX)++" "++float_to_list(LY)++" "++mensagemvivo(MJ)
										end
								end
							end
					end
			end
	end.

% Acrescenta no fim da mensagem
mensagemvivo(MJ) ->
	case ((navedentroecra(MJ) == true) and (impactonavebh(maps:get(pos,MJ)) == false)) of
		true -> "alive\n";
		false -> "dead\n"
	end.

% Mensagem com a pos de todos os planetas
mensagemplanetas(LP) ->
	case lists:map(fun(P) -> maps:get(pos,P) end, LP) of
		[H|T] ->
			"planetas "++auxmensagemplanetas(H)++" "++auxmensagemplanetas(lists:nth(1,T))++" "++auxmensagemplanetas(lists:nth(2,T))++" "++auxmensagemplanetas(lists:nth(3,T))++" "++auxmensagemplanetas(lists:nth(4,T))++" "++auxmensagemplanetas(lists:nth(5,T))++"\n"
	end.

auxmensagemplanetas(H) ->
	case H of
		{X,Y} ->
			float_to_list(X)++" "++float_to_list(Y)
	end.


room(Pids) ->
	receive
		{entrar,Pid} ->
			io:format("user entered ~p ~n", [Pid]),
			room(criarjogo([Pid | Pids]));
		{sair,Pid} ->
			io:format("user left~n", []),
			room(Pids -- [Pid])
	end.

% Cria o jogo e envia mensagem a cada jogador
criarjogo([P|T]) ->
	if
		length([P|T]) >= 2 ->
				Jogo = spawn(fun() -> jogo(P,hd(T),inicionave(#{},"esq"),inicionave(#{},"dir"),planetas()) end),
				P ! {start,Jogo},
				hd(T) ! {start,Jogo},
				[T]--[hd(T)];
		true -> [P|T]
	end.

%Remove o \n no fim
removebarran([_]) -> [];
removebarran([H|T]) -> [H] ++ removebarran(T).


% Parametros inicias de cada nave , MJ	- Map do jogador	Tipo: "esq" ou "dir"
inicionave(MJ,Tipo) ->
	case Tipo of
		"esq" -> maps:put(pos,{150.0,600.0},maps:put(speed,{0.0,0.0},maps:put(accel,{0.0,0.0},maps:put(dir,0.0,maps:put(dirmagright,{0.0,0.0},maps:put(dirmagleft,{0.0,0.0},maps:put(mass,10.0,maps:put(fuel,174.0,MJ))))))));
		"dir" -> maps:put(pos,{1050.0,600.0},maps:put(speed,{0.0,0.0},maps:put(accel,{0.0,0.0},maps:put(dir,0.0,maps:put(dirmagright,{0.0,0.0},maps:put(dirmagleft,{0.0,0.0},maps:put(mass,10.0,maps:put(fuel,174.0,MJ))))))))
	end.

% Inicia lista de planetas
planetas() ->
	[inicioplaneta1(#{})]++[inicioplaneta2(#{})]++[inicioplaneta3(#{})]++[inicioplaneta4(#{})]++[inicioplaneta5(#{})]++[inicioplaneta6(#{})].


% Parametros iniciais de cada planeta
inicioplaneta1(P1) ->
	maps:put(pos,{600.0,550.0},maps:put(speed,{0.0,0.0},maps:put(mass,1.40*math:pow(10,11),maps:put(ang,0.0,maps:put(raio,95,maps:put(vel,1.6,maps:put(angp,0.01,P1))))))).

inicioplaneta2(P2) ->
	maps:put(pos,{700.0,150.0},maps:put(speed,{0.0,0.0},maps:put(mass,1.70*math:pow(10,11),maps:put(ang,0.0,maps:put(raio,120,maps:put(vel,1.0,maps:put(angp,0.01,P2))))))).

inicioplaneta3(P3) ->
	maps:put(pos,{200.0,120.0},maps:put(speed,{0.0,0.0},maps:put(mass,1.20*math:pow(10,11),maps:put(ang,0.0,maps:put(raio,80,maps:put(vel,2.0,maps:put(angp,0.02,P3))))))).


inicioplaneta4(P4) ->
	maps:put(pos,{140.0,350.0},maps:put(speed,{0.0,0.0},maps:put(mass,1.15*math:pow(10,11),maps:put(ang,0.0,maps:put(raio,75,maps:put(vel,1.5,maps:put(angp,0.015,P4))))))).


inicioplaneta5(P5) ->
	maps:put(pos,{400.0,600.0},maps:put(speed,{0.0,0.0},maps:put(mass,1.10*math:pow(10,11),maps:put(ang,0.0,maps:put(raio,65,maps:put(vel,0.9,maps:put(angp,0.009,P5))))))).


inicioplaneta6(P6) ->
	maps:put(pos,{900.0,200.0},maps:put(speed,{0.0,0.0},maps:put(mass,1.35*math:pow(10,11),maps:put(ang,0.0,maps:put(raio,90,maps:put(vel,1.1,maps:put(angp,0.01,P6))))))).

% Atualiza a orbita de todos os planetas
atualizaplanetas(LP) ->
	lists:map(fun(P) -> atualizaposplanetas(P) end,LP).


% Atualiza a posiçao de um planeta , P é o map do planeta
atualizaposplanetas(P) ->
	case maps:get(ang,P) of
		Ang -> 
			case maps:get(vel,P) of 
					Vel -> 
						case maps:get(pos,P) of
							{PX,PY} -> 
								maps:update(speed,{Vel*math:sin(Ang),-Vel*math:cos(Ang)},maps:update(pos,{PX+(Vel*math:sin(Ang)),PY+(-Vel*math:cos(Ang))},maps:update(ang,Ang+(maps:get(angp,P)),P)))				
						end
			end
	end.

% Verfica se nave entrou no BH, {X,Y} - posicao da nave
% nao pode desenhar a nave se isto for true
impactonavebh({X,Y}) ->
	math:pow(X-600,2)+math:pow(Y-350,2) =< math:pow(15,2).

% Verifica se 2 naves colidiram , {PX1,PY1} - Posiçao da nave 1 , {PX2,PY2} - Posiçao da nave 2
impactonavenave({PX1,PY1},{PX2,PY2}) ->
	math:pow(PX1-PX2,2)+math:pow(PY1-PY2,2) =< math:pow(40,2).
		
% Verifica se a nave colidiu com o planeta , {NX,NY} - Posicao da nave , {PX,PY} - Posiçao do planeta , RP - Raio do planeta
impactonaveplaneta({NX,NY},{PX,PY},RP) ->
	math:pow(NX-PX,2)+math:pow(NY-PY,2) =< math:pow(RP/2,2)+600.


% Atualiza as 2 naves apos impacto , MJ1 -> Map da nave 1, MJ2 -> Map da nave 2
atualizaspeedimpactonn(MJ1,MJ2) ->
	case {maps:get(pos,MJ1),maps:get(pos,MJ2)} of
		{{X1,Y1},{X2,Y2}} -> 
			case maps:get(speed,MJ1) of
				{SX,SY} -> maps:update(speed,{SX+(0.1*(math:sin(math:pi()+math:atan2(X2-X1,Y2-Y1)))),SY+(0.1*(math:cos(math:pi()+math:atan2(X2-X1,Y2-Y1))))},MJ1)
			end
	end.

% Atualiza a nave apos impacto com planeta , MJ -> Nave , P -> Planeta
atualizaspeedimpactoplan(MJ,P) ->
	case maps:get(pos,P) of
		{PX,PY} ->
			case maps:get(pos,MJ) of
				{NX,NY} ->
					AA = math:pi()+math:atan2(PX-NX,PY-NY),
					case maps:get(speed,MJ) of
						{SX,SY} ->
							maps:update(speed,{SX+(0.1*math:sin(AA)),SY+(0.1*math:cos(AA))},MJ)
					end
			end
	end.

% É fazer sempre atualizaposimpactonn(atualizaspeedimpactonn(MJ1,MJ2)) para o jogador 1
% e fazer sempre atualizaposimpactonn(atualizaspeedimpactonn(MJ2,MJ1)) para o jogador 2
% fazer isto se impactonavenave({PX1,PY1},{PX2,PY2}) == true
atualizaposimpactonn(MJ1) ->
	case maps:get(speed,MJ1) of
		{SX,SY} -> 
			case maps:get(pos,MJ1) of
				{PX,PY} -> 
					maps:update(pos,{PX+SX,PY+SY},MJ1)
			end
	end.


% É fazer sempre atualizaposimpactoplan(atualizaspeedimpactoplan(MJ,P))
% fazer isto se impactonaveplaneta({NX,NY},{PX,PY},RP) == true
atualizaposimpactoplan(MJ) ->
	case maps:get(speed,MJ) of
		{SX,SY} ->
			case maps:get(pos,MJ) of
				{PX,PY} ->
					maps:update(pos,{PX+SX,PY+SY},MJ)
			end
	end.

% Atualiza a speed da nave apos a gravidade do planeta
atualizaspeedgravplaneta(MJ,P) ->
	Calculo1 = calculof1naveplaneta(MJ,P),
	Angulo1 = angulonaveplaneta(MJ,P),
	case maps:get(speed,MJ) of
		{SX,SY} ->
			maps:update(speed,{SX+(Calculo1*math:sin(Angulo1)),SY+(-Calculo1*math:cos(Angulo1))},MJ)
	end.


% Atualiza a speed da nave apos a gravidade do BH
atualizaspeedgravbh(MJ) ->
	Calculo1 = calculof1bh(MJ),
	Angulo1 = angulonavebh(MJ),
	case maps:get(speed,MJ) of
		{SX,SY} -> 
			maps:update(speed,{SX+(Calculo1*math:sin(Angulo1)),SY+(-Calculo1*math:cos(Angulo1))},MJ)
	end.


% É fazer sempre atualizaposgravplaneta((atualizaspeedgravplaneta(MJ,P)))
% Atualiza a pos da nave apos a gravidade do planeta
% So fazer isto se impactonaveplaneta(MJ,P) == false
atualizaposgravplaneta(MJ) ->
	case maps:get(pos,MJ) of
		{X,Y} -> 
			case maps:get(speed,MJ) of
				{SX,SY} ->
					maps:update(pos,{X+SX,Y+SY},MJ)
			end
	end.

% É fazer sempre atualizaposgravbh(atualizaspeedgravbh(MJ))
% Atualiza a pos da nave apos a gravidade do BH
% So fazer isto se impactonavebh(MJ) == false
atualizaposgravbh(MJ) ->
	case maps:get(pos,MJ) of
		{X,Y} -> 
			case maps:get(speed,MJ) of
				{SX,SY} ->
					maps:update(pos,{X+SX,Y+SY},MJ)
			end
	end.


% Calculo auxiliar de aux = g*mship*massplaneta
calculoauxiliarforcaplaneta(P) ->
	Mass = maps:get(mass,P),
	constgrav()*10*Mass.


% Calculo auxiliar de aux = g*mship*massbh
calculoauxiliarforcabh() ->
	constgrav()*10*massbh().

% Calculo auxiliar de aux/pow(d1,2) para o BH
calculof1bh(MJ) ->
	calculoauxiliarforcabh()/math:pow(distancianavebh(MJ),2).

% Calculo auxiliar de aux/pow(d1,2) para os planetas
calculof1naveplaneta(MJ,P) ->
	calculoauxiliarforcaplaneta(P)/math:pow(distancianaveplaneta(MJ,P),2).

% Calcula a distancia entre a nave e o planeta - {PX,PY} é a pos do planeta, {NX,NY} é a pos da nave
distancianaveplaneta(MJ,P) ->
	case maps:get(pos,P) of
		{PX,PY} ->
			case maps:get(pos,MJ) of
				{NX,NY} ->
					math:sqrt((math:pow(PX-NX,2))+(math:pow(PY-NY,2)))
			end
	end.


% Calcula a distancia entre a nave e o bh - X e Y é a pos da nave
distancianavebh(MJ) ->
	case maps:get(pos,MJ) of
		{X,Y} -> 
			math:sqrt((math:pow(600-X,2))+(math:pow(350-Y,2)))
	end.

% Calcula o angulo com o planeta, MJ é a nave e P é o planeta
angulonaveplaneta(MJ,P) ->
	case maps:get(pos,P) of
		{PX,PY} ->
			case maps:get(pos,MJ) of
				{NX,NY} -> math:pi() - math:atan2(PX-NX,PY-NY)
			end
	end.


% Calcula o angulo com o BH, MJ é a nave
angulonavebh(MJ) -> 
	case maps:get(pos,MJ) of
		{X,Y} -> 
			math:pi() - math:atan2(600-X,350-Y)
	end.

% Verifica se a nave está dentro do ecra
navedentroecra(MJ) ->
	case maps:get(pos,MJ) of
		{X,Y} ->
			(X > 0) and (X < 1200) and (Y > 0) and (Y < 700)
	end.

% Movimento rot esquerda , MJ - Nave
rotacaoesquerda(MJ) ->
	case maps:get(fuel,MJ) of
		Fuel ->
			case temcombustivelrot(MJ) of
				true ->
					case maps:get(dir,MJ) of
						Dir ->
							Tmx = 0.5 * math:sin(Dir-(5.0*math:pi()/180)),
							Tmy = -0.5 * math:cos(Dir-(5.0*math:pi()/180)),
							maps:update(fuel,Fuel-0.5,maps:update(dir,Dir-(5*math:pi()/180),maps:update(dirmagright,{Tmx,Tmy},MJ)))
					end;
				false ->
					MJ
			end
	end.

% Verifica se tem combustivel para rotaçao
temcombustivelrot(MJ) ->
	case maps:get(fuel,MJ) of
		Fuel ->
			Fuel >= 0.5
	end.

% Verifica se tem combustivel para accel
temcombustivelaccel(MJ) -> 
	case maps:get(fuel,MJ) of
		Fuel ->
			Fuel >= 2.0
	end.

% Movimento rot direita , MJ - Nave
rotacaodireita(MJ) ->
	case maps:get(fuel,MJ) of
		Fuel ->
			case temcombustivelrot(MJ) of
				true ->
					case maps:get(dir,MJ) of
						Dir ->
							Tmx = 0.5 * math:sin(Dir+(5.0*math:pi()/180)),
							Tmy = -0.5 * math:cos(Dir+(5.0*math:pi()/180)),
							maps:update(fuel,Fuel-0.5,maps:update(dir,Dir+(5*math:pi()/180),maps:update(dirmagleft,{Tmx,Tmy},MJ)))
					end;
				false ->
					MJ
			end
	end.

% aux Movimento aceleraçao, MJ - Nave
accmovimentofrente(MJ) ->
	case maps:get(fuel,MJ) of
		Fuel ->
			case temcombustivelaccel(MJ) of
				true ->
					case maps:get(dir,MJ) of
						Dir ->
							maps:update(fuel,Fuel-2.0,maps:update(accel,{0.1*math:sin(Dir),-0.1*math:cos(Dir)},MJ))
					end;
				false ->
					MJ
			end
	end.

% Movimento aceleraçao, MJ - Nave
% fazer sempre movimentofrente(accmovimentofrente(MJ))
movimentofrente(MJ) ->
	case maps:get(pos,MJ) of
		{PX,PY} ->
			case maps:get(speed,MJ) of
				{SX,SY} ->
					case maps:get(accel,MJ) of
						{AX,AY} ->
							maps:update(speed,{SX+AX,SY+AY},maps:update(pos,{PX+(SX+AX),PY+(SY+AY)},MJ))
					end
			end
	end.

% Reset aceleraçao
resetaccel(MJ) ->
	maps:update(accel,{0.0,0.0},MJ).

% Reset dirmags
resetdirmag(MJ) ->
	maps:update(dirmagleft,{0.0,0.0},maps:update(dirmagright,{0.0,0.0},MJ)).

% Massa do buraco negro
massbh() ->
	2.00*math:pow(10,11).

% Constante gravidade
constgrav() ->
	6.67*math:pow(10,-11).
