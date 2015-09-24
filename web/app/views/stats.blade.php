<?php
$data = Site::where('id', 0)->get();
$data = $data[0];

function custom_number_format($i) {

	if($i > 9999999) {

		if($i <= 999999999) {
			/// use millions

			return $i / 1000000 + " mil";

		} else {
			/// use billions

			return $i / 1000000000 + " bil";
		}

	} else return number_format($i);

}
?>

<div class="boards-section" id="stats">
	<div class="column" id="wide">
		<h1 class="reset"><small>daily statistics for</small> {{ date("F j") }}<sup>{{ date("S") }}</sup>, {{ date("Y") }}</h1>
		<div class="boxes">
			<div class="box full">
				<div>{{ custom_number_format($data->current_match_count) }}</div>
				<small>matches recorded today</small>
			</div>

			<div class="box third">
				<div>{{ custom_number_format($data->current_kills) }}</div>
				<small>kills</small>
			</div>
			<div class="box third">
				<div>{{ custom_number_format($data->current_deaths) }}</div>
				<small>deaths</small>
			</div>
			<div class="box third">
				<div>{{ custom_number_format($data->current_assists) }}</div>
				<small>assists</small>
			</div>

			<div class="box full">
				<div>{{ custom_number_format(round($data->current_duration / 60)) }}</div>
				<small>hours of play recorded</small>
			</div>

			<div class="box full">
				<div>{{ $data->steam_down_at->diffForHumans() }}</div>
				<small>last service outage</small>
			</div>
		</div>
	</div>
	<div class="column" id="wide">
		<h1 class="reset"><small>all-time statistics over</small> {{ $data->days_online }} days</h1>
		<div class="boxes">
			<div class="box full">
				<div>{{ custom_number_format($data->total_match_count) }}</div>
				<small>matches recorded</small>
			</div>

			<div class="box third">
				<div>{{ custom_number_format($data->total_kills) }}</div>
				<small>kills</small>
			</div>
			<div class="box third">
				<div>{{ custom_number_format($data->total_deaths) }}</div>
				<small>deaths</small>
			</div>
			<div class="box third">
				<div>{{ custom_number_format($data->total_assists) }}</div>
				<small>assists</small>
			</div>

			<div class="box full">
				<div>{{ custom_number_format(round($data->total_duration / 60)) }}</div>
				<small>hours of play recorded</small>
			</div>
		</div>
	</div>
	@include("stats/primary")
</div>